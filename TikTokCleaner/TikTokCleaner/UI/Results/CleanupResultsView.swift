import SwiftUI

/// Écran de bilan final après exécution du nettoyage.
public struct CleanupResultsView: View {
    public let summary: CleanupSummary?
    public let onStartNewCleanup: () -> Void
    
    @State private var showErrorsSheet = false
    
    public init(summary: CleanupSummary?, onStartNewCleanup: @escaping () -> Void) {
        self.summary = summary
        self.onStartNewCleanup = onStartNewCleanup
    }
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icône de succès
                ZStack {
                    Circle()
                        .fill(hasErrors ? Color.appWarning.opacity(0.15) : Color.appSuccess.opacity(0.15))
                        .frame(width: 84, height: 84)
                    
                    Image(systemName: hasErrors ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                        .font(.system(size: 44))
                        .foregroundColor(hasErrors ? .appWarning : .appSuccess)
                }
                
                // Titre et Sous-titre
                VStack(spacing: 8) {
                    Text("NETTOYAGE TERMINÉ")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    Text("\(summary?.totalPlanned ?? 0) éléments traités")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
                
                // Cartes de résultats
                VStack(spacing: 12) {
                    // Supprimés
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.appSuccess)
                                .font(.system(size: 18))
                            Text("Supprimés")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.appTextPrimary)
                        }
                        Spacer()
                        Text("\(summary?.successfulCount ?? 0)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.appSuccess)
                    }
                    .padding(16)
                    .background(Color.appCard)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appCardBorder, lineWidth: 1))
                    
                    // Non traités / Erreurs
                    if hasErrors {
                        HStack {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.appWarning)
                                    .font(.system(size: 18))
                                Text("Non traités")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.appTextPrimary)
                            }
                            Spacer()
                            Text("\(summary?.failedCount ?? 0)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.appWarning)
                        }
                        .padding(16)
                        .background(Color.appCard)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appWarning.opacity(0.3), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
                
                // Durée de traitement
                if let duration = summary?.formattedDuration {
                    Text("Temps d'exécution total : \(duration)")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextMuted)
                }
                
                Spacer()
                
                // Boutons d'action
                VStack(spacing: 12) {
                    if hasErrors {
                        TikTokButton(
                            title: "Voir les erreurs (\(summary?.failedTasks.count ?? 0))",
                            icon: "list.bullet.rectangle",
                            style: .outline
                        ) {
                            showErrorsSheet = true
                        }
                    }
                    
                    TikTokButton(
                        title: "Nouveau nettoyage",
                        icon: "arrow.clockwise",
                        style: .primary
                    ) {
                        onStartNewCleanup()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
        .sheet(isPresented: $showErrorsSheet) {
            ErrorDetailSheet(failedTasks: summary?.failedTasks ?? [])
        }
    }
    
    private var hasErrors: Bool {
        (summary?.failedCount ?? 0) > 0
    }
}
