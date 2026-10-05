import Foundation
import SwiftUI
import Combine

/// Modèle de vue pilotant le banc d'essai d'un like unique en conditions réelles.
public final class SingleLikeTestViewModel: ObservableObject {
    @Published public var videoInput: String = ""
    @Published public var isRunningTest: Bool = false
    @Published public var currentStepText: String = ""
    @Published public var lastReport: SingleLikeTestReport? = nil
    @Published public var errorMessage: String? = nil
    
    public let authManager = AuthManager.shared
    
    public init() {}
    
    public var extractedAwemeId: String? {
        let trimmed = videoInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return GDPRArchiveScanner.shared.extractAwemeId(from: trimmed)
    }
    
    @MainActor
    public func runEndToEndTest() async {
        guard let awemeId = extractedAwemeId, !awemeId.isEmpty else {
            errorMessage = "Veuillez coller une URL ou un identifiant de vidéo valide."
            return
        }
        
        errorMessage = nil
        lastReport = nil
        isRunningTest = true
        
        // Étape 1 : Vérification de la session
        currentStepText = "1/5 • Vérification de la session TikTok..."
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Étape 2 : Chargement du contexte WebKit
        currentStepText = "2/5 • Chargement du runtime TikTok et de la vidéo..."
        
        // Étape 3 : Exécution du test strict
        currentStepText = "3/5 • Inspection de l'état AVANT (userDigged == 1)..."
        
        do {
            let report = try await WebKitSessionExecutor.shared.executeSingleLikeEndToEndTest(awemeId: awemeId)
            self.lastReport = report
            self.isRunningTest = false
            self.currentStepText = report.isSuccess ? "✅ Test validé avec succès !" : "❌ Échec des critères de validation"
        } catch {
            self.isRunningTest = false
            self.errorMessage = error.localizedDescription
            self.currentStepText = "❌ Erreur durant le test"
        }
    }
    
    public func openVideoInTikTok() {
        guard let awemeId = extractedAwemeId,
              let url = URL(string: "https://www.tiktok.com/@/video/\(awemeId)") else { return }
        UIApplication.shared.open(url)
    }
}
