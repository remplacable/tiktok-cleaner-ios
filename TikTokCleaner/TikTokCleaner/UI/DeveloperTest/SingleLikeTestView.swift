import SwiftUI

/// Écran de diagnostic développeur pour valider la suppression réelle d'un like unique.
public struct SingleLikeTestView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = SingleLikeTestViewModel()
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var showLoginSheet = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barre de titre
                topBar
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Statut du compte connecté
                        accountStatusBanner
                        
                        // Champ de saisie de la vidéo
                        videoInputSection
                        
                        // Bouton de lancement
                        launchButton
                        
                        // Progression des étapes
                        if viewModel.isRunningTest {
                            runningProgressView
                        }
                        
                        // Résultat et diagnostic complet
                        if let report = viewModel.lastReport {
                            testResultBanner(report)
                            developerDiagnosticCard(report)
                        } else if let error = viewModel.errorMessage {
                            errorCard(error)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginSheetView()
        }
    }
    
    // MARK: - Composants
    
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("BANC D'ESSAI — LIKE RÉEL")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                Text("Validation stricte de bout en bout sur TikTok")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
            }
            Spacer()
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.appTextMuted)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    private var accountStatusBanner: some View {
        GlassCard(padding: 14) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 22))
                    .foregroundColor(.tiktokCyan)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(authManager.currentAccount?.displayName ?? "Compte TikTok non connecté")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    Text("@\(authManager.currentAccount?.username ?? "inconnu") • \(authManager.currentAccount?.connectionMethod.rawValue ?? "")")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                Button("Changer") {
                    showLoginSheet = true
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.tiktokRed)
            }
        }
    }
    
    private var videoInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("IDENTIFICATION DE LA VIDÉO AIMÉE")
                .sectionHeaderStyle()
            
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.appTextMuted)
                    
                    TextField("Collez le lien ou l'ID TikTok de la vidéo...", text: $viewModel.videoInput)
                        .foregroundColor(.appTextPrimary)
                        .font(.system(size: 14))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !viewModel.videoInput.isEmpty {
                        Button(action: { viewModel.videoInput = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.appTextMuted)
                        }
                    }
                }
                .padding(14)
                .background(Color.appCard)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appCardBorder, lineWidth: 1))
                
                if let awemeId = viewModel.extractedAwemeId {
                    HStack {
                        Text("ID vidéo détecté :")
                            .font(.system(size: 12))
                            .foregroundColor(.appTextMuted)
                        Text(awemeId)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.tiktokCyan)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private var launchButton: some View {
        TikTokButton(
            title: "TESTER LA SUPPRESSION DE CE LIKE",
            icon: "play.circle.fill",
            style: .primary,
            isLoading: viewModel.isRunningTest
        ) {
            Task {
                await viewModel.runEndToEndTest()
            }
        }
        .disabled(viewModel.extractedAwemeId == nil || viewModel.isRunningTest)
    }
    
    private var runningProgressView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .tiktokRed))
                .scaleEffect(1.2)
            
            Text(viewModel.currentStepText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.appCard)
        .cornerRadius(14)
    }
    
    private func testResultBanner(_ report: SingleLikeTestReport) -> some View {
        VStack(spacing: 14) {
            if report.isSuccess {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appSuccess)
                        
                        Text("LIKE SUPPRIMÉ AVEC SUCCÈS")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.appSuccess)
                    }
                    
                    Text("Le critère absolu a été satisfait : la vidéo était bien likée (1), a été supprimée sur TikTok, et est confirmée non likée (0).")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.appSuccess.opacity(0.12))
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appSuccess.opacity(0.4), lineWidth: 1))
                
                TikTokButton(
                    title: "Ouvrir TikTok pour vérification visuelle",
                    icon: "arrow.up.right.square",
                    style: .outline
                ) {
                    viewModel.openVideoInTikTok()
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.octagon.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.appError)
                        Text("ÉCHEC DU CRITÈRE DE VALIDATION")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appError)
                    }
                    
                    Text(report.errorMessage ?? "La vidéo n'a pas pu être validée comme supprimée.")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextPrimary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appError.opacity(0.12))
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appError.opacity(0.4), lineWidth: 1))
            }
        }
    }
    
    private func developerDiagnosticCard(_ report: SingleLikeTestReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RAPPORT DÉTAILLÉ DU MOTEUR (ZÉRO SECRET)")
                .sectionHeaderStyle()
            
            GlassCard(padding: 16) {
                VStack(spacing: 10) {
                    diagnosticRow(label: "Endpoint TikTok", value: report.endpointUsed, highlight: false)
                    Divider().background(Color.appCardBorder)
                    diagnosticRow(label: "Code HTTP", value: "\(report.httpStatusCode)", highlight: report.httpStatusCode == 200)
                    Divider().background(Color.appCardBorder)
                    diagnosticRow(label: "status_code TikTok", value: "\(report.tiktokStatusCode)", highlight: report.tiktokStatusCode == 0)
                    Divider().background(Color.appCardBorder)
                    diagnosticRow(label: "status_msg TikTok", value: report.tiktokStatusMsg, highlight: false)
                    Divider().background(Color.appCardBorder)
                    diagnosticRow(label: "userDigged AVANT", value: "\(report.userDiggedBefore ?? -1)", highlight: report.userDiggedBefore == 1)
                    Divider().background(Color.appCardBorder)
                    diagnosticRow(label: "userDigged APRÈS", value: "\(report.userDiggedAfter ?? -1)", highlight: report.userDiggedAfter == 0)
                    Divider().background(Color.appCardBorder)
                    diagnosticRow(label: "Durée de la requête", value: report.formattedDuration, highlight: false)
                    Divider().background(Color.appCardBorder)
                    diagnosticRow(label: "Défi sécurité / Captcha", value: report.securityChallengeEncountered ? "DÉTECTÉ ⚠️" : "Aucun blocage ✓", highlight: !report.securityChallengeEncountered)
                }
            }
        }
    }
    
    private func diagnosticRow(label: String, value: String, highlight: Bool) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.appTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(highlight ? .appSuccess : .appTextPrimary)
        }
    }
    
    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.appError)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.appTextPrimary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appError.opacity(0.12))
        .cornerRadius(12)
    }
}
