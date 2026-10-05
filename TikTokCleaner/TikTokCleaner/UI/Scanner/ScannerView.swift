import SwiftUI

/// Vue d'analyse du compte TikTok avec progression multi-catégorie.
public struct ScannerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = ScannerViewModel()
    @ObservedObject private var scanner = ContentScanner.shared
    
    public let onProceedToClean: () -> Void
    
    public init(onProceedToClean: @escaping () -> Void) {
        self.onProceedToClean = onProceedToClean
    }
    
    public var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Barre de fermeture
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.cancel()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appTextMuted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Titre et Statut
                VStack(spacing: 8) {
                    if scanner.isScanCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.appSuccess)
                            .transition(.scale)
                        
                        Text("Analyse terminée")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        
                        Text("Tous les éléments analysables ont été répertoriés.")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .tiktokRed))
                            .scaleEffect(1.3)
                            .padding(.bottom, 6)
                        
                        Text("Analyse du compte...")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        
                        Text("Récupération en direct des données locales et distantes")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                    }
                }
                
                // Liste de progression par catégorie
                GlassCard(padding: 20) {
                    VStack(spacing: 20) {
                        ForEach(CleanupCategory.allCases) { category in
                            categoryProgressRow(for: category)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Résumé chiffré quand l'analyse est terminée
                if scanner.isScanCompleted {
                    summaryResultGrid
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
                
                // Bouton d'action
                VStack(spacing: 12) {
                    if scanner.isScanCompleted {
                        TikTokButton(title: "Nettoyer", icon: "trash.fill", style: .primary) {
                            presentationMode.wrappedValue.dismiss()
                            onProceedToClean()
                        }
                    } else {
                        TikTokButton(title: "Arrêter l'analyse", style: .secondary) {
                            viewModel.cancel()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            if !viewModel.hasStarted {
                viewModel.startScanning()
            }
        }
    }
    
    // MARK: - Sous-Vues
    
    private func categoryProgressRow(for category: CleanupCategory) -> some View {
        let progress = scanner.categoryProgress[category] ?? 0.0
        let count = scanner.scannedCounts[category] ?? 0
        
        return VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: category.iconName)
                        .font(.system(size: 15))
                        .foregroundColor(category.symbolColor)
                    
                    Text(category.displayName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.appTextPrimary)
                }
                
                Spacer()
                
                if scanner.isScanCompleted {
                    Text("\(count) trouvés")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.appTextPrimary)
                } else {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            ModernProgressBar(
                progress: progress,
                tintColor: category.symbolColor,
                height: 7
            )
        }
    }
    
    private var summaryResultGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                summaryChip(count: scanner.scannedCounts[.likes] ?? 0, title: "likes", color: .tiktokRed)
                summaryChip(count: scanner.scannedCounts[.posts] ?? 0, title: "vidéos", color: .tiktokCyan)
            }
            HStack(spacing: 14) {
                summaryChip(count: scanner.scannedCounts[.reposts] ?? 0, title: "republications", color: .purple)
                summaryChip(count: scanner.scannedCounts[.favorites] ?? 0, title: "favoris", color: .yellow)
            }
        }
    }
    
    private func summaryChip(count: Int, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Text("\(count)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.appCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appCardBorder, lineWidth: 1)
        )
    }
}
