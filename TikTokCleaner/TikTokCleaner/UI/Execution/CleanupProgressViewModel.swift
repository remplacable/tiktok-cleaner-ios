import Foundation
import Combine

/// Modèle de vue contrôlant l'écran d'avancement du nettoyage.
public final class CleanupProgressViewModel: ObservableObject {
    public let engine = CleanupEngine.shared
    public let progressManager = ProgressManager.shared
    
    @Published public var showCancelAlert = false
    @Published public var showResultsView = false
    
    public init() {}
    
    public func togglePause() {
        if engine.isPaused {
            engine.resume()
        } else {
            engine.pause()
        }
    }
    
    public func confirmCancel() {
        engine.cancel()
    }
}
