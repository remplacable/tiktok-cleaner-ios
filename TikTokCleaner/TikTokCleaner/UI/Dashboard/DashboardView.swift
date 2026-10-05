import SwiftUI

/// Tableau de bord central de TikTok Cleaner.
public struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var cleanupEngine = CleanupEngine.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // En-tête compte utilisateur
                        accountHeaderView
                        
                        // Grille des statistiques du compte
                        statsGridView
                        
                        // Bloc des actions principales
                        actionButtonsView
                        
                        // Carte de réassurance technique et sécurité
                        securityPillView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 36)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.tiktokRed)
                        Text("TikTok Cleaner")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showSettingsSheet = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                            .frame(width: 38, height: 38)
                            .background(Color.appCard)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.appCardBorder, lineWidth: 1))
                    }
                }
            }
            // Feuilles modales
            .sheet(isPresented: $viewModel.showScannerSheet) {
                ScannerView {
                    // Si l'utilisateur clique sur "Nettoyer" depuis le scan
                    viewModel.showCustomCleanupSheet = true
                }
            }
            .sheet(isPresented: $viewModel.showCustomCleanupSheet) {
                CustomCleanupView { config in
                    CleanupEngine.shared.startCleanup(configuration: config)
                    viewModel.showExecutionView = true
                }
            }
            .sheet(isPresented: $viewModel.showSettingsSheet) {
                SettingsView()
            }
            .sheet(isPresented: $viewModel.showLoginSheet) {
                LoginSheetView()
            }
            .sheet(isPresented: $viewModel.showGDPRImportSheet) {
                GDPRImportView()
            }
            .sheet(item: $viewModel.showManualSelectionCategory) { category in
                ManualSelectionView(category: category)
            }
            .sheet(isPresented: $viewModel.showSingleLikeTestSheet) {
                SingleLikeTestView()
            }
            .fullScreenCover(isPresented: $viewModel.showExecutionView) {
                CleanupProgressView {
                    viewModel.showExecutionView = false
                }
            }
            .alert(isPresented: $viewModel.showQuickCleanupConfirmation) {
                Alert(
                    title: Text("Nettoyage rapide"),
                    message: Text("Voulez-vous lancer le nettoyage automatique des Likes et Republications ?"),
                    primaryButton: .destructive(Text("Nettoyer")) {
                        viewModel.startQuickCleanup()
                    },
                    secondaryButton: .cancel(Text("Annuler"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Sous-Vues
    
    private var accountHeaderView: some View {
        GlassCard(padding: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.tiktokRed, Color.tiktokCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 54, height: 54)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(authManager.currentAccount?.displayName ?? "Compte TikTok")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.tiktokCyan)
                    }
                    
                    Text("@\(authManager.currentAccount?.username ?? "utilisateur")")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.appTextSecondary)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.appSuccess)
                            .frame(width: 6, height: 6)
                        
                        Text(authManager.currentAccount?.connectionMethod.rawValue ?? "Connecté")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appTextMuted)
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
                
                Button(action: { viewModel.showLoginSheet = true }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                        .padding(10)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private var statsGridView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("VOTRE COMPTE")
                    .sectionHeaderStyle()
                Spacer()
                Text("Touchez une carte pour filtrer")
                    .font(.system(size: 11))
                    .foregroundColor(.appTextMuted)
            }
            
            LazyVGrid(columns: columns, spacing: 14) {
                StatCard(
                    category: .likes,
                    count: authManager.currentAccount?.likesCount ?? 1284,
                    onTap: { viewModel.showManualSelectionCategory = .likes }
                )
                
                StatCard(
                    category: .posts,
                    count: authManager.currentAccount?.videosCount ?? 42,
                    onTap: { viewModel.showManualSelectionCategory = .posts }
                )
                
                StatCard(
                    category: .reposts,
                    count: authManager.currentAccount?.repostsCount ?? 316,
                    onTap: { viewModel.showManualSelectionCategory = .reposts }
                )
                
                StatCard(
                    category: .favorites,
                    count: authManager.currentAccount?.favoritesCount ?? 892,
                    onTap: { viewModel.showManualSelectionCategory = .favorites }
                )
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            TikTokButton(
                title: "Scanner mon compte",
                icon: "waveform.path.badge.plus",
                style: .primary
            ) {
                viewModel.showScannerSheet = true
            }
            
            TikTokButton(
                title: "Nettoyage rapide",
                icon: "bolt.fill",
                style: .secondary
            ) {
                viewModel.showQuickCleanupConfirmation = true
            }
            
            TikTokButton(
                title: "Nettoyage personnalisé",
                icon: "slider.horizontal.below.rectangle",
                style: .outline
            ) {
                viewModel.showCustomCleanupSheet = true
            }
            
            TikTokButton(
                title: "Banc d'essai • Test réel 1 Like",
                icon: "hammer.fill",
                style: .secondary
            ) {
                viewModel.showSingleLikeTestSheet = true
            }
        }
    }
    
    private var securityPillView: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 18))
                .foregroundColor(.tiktokCyan)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Exécution 100% locale et sécurisée")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                Text("Aucune donnée n'est transmise à un serveur tiers.")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextMuted)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.appCard.opacity(0.6))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.appCardBorder.opacity(0.8), lineWidth: 1)
        )
    }
}
