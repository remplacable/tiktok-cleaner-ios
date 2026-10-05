import SwiftUI

/// Écran d'exécution du nettoyage avec suivi en direct de la file d'attente.
public struct CleanupProgressView: View {
    @StateObject private var viewModel = CleanupProgressViewModel()
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var engine = CleanupEngine.shared
    
    public let onDismiss: () -> Void
    
    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if progressManager.state.isFinished {
                CleanupResultsView(summary: progressManager.lastSummary) {
                    onDismiss()
                }
            } else {
                activeProgressBody
            }
        }
        .preferredColorScheme(.dark)
        .alert(isPresented: $viewModel.showCancelAlert) {
            Alert(
                title: Text("Interrompre le nettoyage ?"),
                message: Text("Les éléments déjà supprimés ne pourront pas être restaurés. Vous pourrez reprendre ultérieurement pour le reste."),
                primaryButton: .destructive(Text("Arrêter définitivement")) {
                    viewModel.confirmCancel()
                    onDismiss()
                },
                secondaryButton: .cancel(Text("Continuer"))
            )
        }
    }
    
    // MARK: - Vue Active
    
    private var activeProgressBody: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Statut et Titre
            VStack(spacing: 10) {
                Text(engine.isPaused ? "Nettoyage en pause" : "Nettoyage en cours")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                
                HStack(spacing: 8) {
                    Image(systemName: progressManager.state.currentCategory.iconName)
                        .foregroundColor(progressManager.state.currentCategory.symbolColor)
                    Text(progressManager.state.currentCategory.displayName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            // Jauge et Pourcentage principal
            VStack(spacing: 16) {
                Text(progressManager.state.percentageString)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                ModernProgressBar(
                    progress: progressManager.state.progressRatio,
                    tintColor: .tiktokRed,
                    height: 12
                )
                .padding(.horizontal, 30)
                
                Text("\(progressManager.state.processedItems) / \(progressManager.state.totalItems)")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(.appTextSecondary)
            }
            .padding(.vertical, 10)
            
            // Compteurs Succès et Erreurs
            HStack(spacing: 16) {
                // Succès
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.appSuccess)
                    
                    Text("\(progressManager.state.successCount) supprimés")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.appSuccess.opacity(0.12))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appSuccess.opacity(0.3), lineWidth: 1)
                )
                
                // Erreurs
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.appWarning)
                    
                    Text("\(progressManager.state.errorCount) erreurs")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.appWarning.opacity(0.12))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appWarning.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Estimation temps restant
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextMuted)
                Text("Temps estimé restant : \(progressManager.state.estimatedRemainingTimeFormatted)")
                    .font(.system(size: 13))
                    .foregroundColor(.appTextMuted)
            }
            
            Spacer()
            
            // Boutons de contrôle : Pause / Reprendre & Annuler
            HStack(spacing: 16) {
                TikTokButton(
                    title: engine.isPaused ? "Reprendre" : "Pause",
                    icon: engine.isPaused ? "play.fill" : "pause.fill",
                    style: .secondary
                ) {
                    viewModel.togglePause()
                }
                
                TikTokButton(
                    title: "Annuler",
                    icon: "xmark",
                    style: .destructive
                ) {
                    viewModel.showCancelAlert = true
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
    }
}
