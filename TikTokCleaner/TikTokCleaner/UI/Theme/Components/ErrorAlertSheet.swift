import SwiftUI

/// Vue modale détaillée affichant la cause racine d'une erreur et les actions concrètes recommandées.
public struct ErrorAlertSheet: View {
    public let error: CleanupError
    public var onRetry: (() -> Void)?
    public var onDismiss: () -> Void
    
    public init(error: CleanupError, onRetry: (() -> Void)? = nil, onDismiss: @escaping () -> Void) {
        self.error = error
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Icône et En-tête
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.appError.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.appError)
                }
                
                Text(error.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 10)
            
            // Détails structurés : Cause et Action
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("CAUSE")
                        .sectionHeaderStyle()
                    
                    Text(error.cause)
                        .font(.system(size: 15))
                        .foregroundColor(.appTextSecondary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.appCard)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.appCardBorder, lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("ACTION RECOMMANDÉE")
                        .sectionHeaderStyle()
                    
                    Text(error.action)
                        .font(.system(size: 15))
                        .foregroundColor(.appTextPrimary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.tiktokCyan.opacity(0.08))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.tiktokCyan.opacity(0.3), lineWidth: 1)
                )
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: 12) {
                if error.isRetryable, let onRetry = onRetry {
                    TikTokButton(title: "Réessayer", icon: "arrow.clockwise", style: .primary) {
                        onDismiss()
                        onRetry()
                    }
                }
                
                TikTokButton(title: "Fermer", style: .secondary) {
                    onDismiss()
                }
            }
        }
        .padding(24)
        .background(Color.appBackground)
    }
}
