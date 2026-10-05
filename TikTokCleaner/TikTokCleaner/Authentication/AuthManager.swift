import Foundation
import Combine

/// Gestionnaire central de l'authentification et de l'état du compte.
public final class AuthManager: ObservableObject {
    public static let shared = AuthManager()
    
    @Published public private(set) var currentAccount: TikTokAccount?
    @Published public private(set) var authStatus: AuthStatus = .unauthenticated
    
    private init() {
        restoreSessionIfAvailable()
    }
    
    /// Tente de restaurer une session existante depuis le Keychain
    public func restoreSessionIfAvailable() {
        if KeychainManager.shared.hasCredentials() {
            if let savedData = KeychainManager.shared.getData(forKey: .accountMetadata),
               let savedAccount = try? JSONDecoder().decode(TikTokAccount.self, from: savedData) {
                self.currentAccount = savedAccount
                self.authStatus = .authenticated(account: savedAccount)
                AppLogger.shared.info(category: "AUTH", message: "Compte restauré : @\(savedAccount.username)")
                return
            }
        }
        
        // Par défaut au premier lancement pour une expérience immédiate sans friction
        loadDemoAccount()
    }
    
    /// Charge un compte de démonstration pour tester et inspecter l'application
    public func loadDemoAccount() {
        let demo = TikTokAccount(
            id: "user_demo_prod",
            username: "alex_creatif",
            displayName: "Alex Dupont",
            avatarUrl: nil,
            followerCount: 1420,
            followingCount: 380,
            likesCount: 1284,
            videosCount: 42,
            repostsCount: 316,
            favoritesCount: 892,
            connectionMethod: .demoAccount,
            lastSyncDate: Date()
        )
        self.currentAccount = demo
        self.authStatus = .authenticated(account: demo)
        saveAccountMetadata(demo)
        AppLogger.shared.info(category: "AUTH", message: "Mode Démonstration actif avec statistiques réalistes.")
    }
    
    /// Enregistre une connexion directe par session in-app
    public func setDirectSessionAccount(username: String, displayName: String, likes: Int, videos: Int, reposts: Int, favorites: Int) {
        let account = TikTokAccount(
            id: UUID().uuidString,
            username: username,
            displayName: displayName,
            avatarUrl: nil,
            followerCount: 0,
            followingCount: 0,
            likesCount: likes,
            videosCount: videos,
            repostsCount: reposts,
            favoritesCount: favorites,
            connectionMethod: .directSession,
            lastSyncDate: Date()
        )
        self.currentAccount = account
        self.authStatus = .authenticated(account: account)
        saveAccountMetadata(account)
        AppLogger.shared.info(category: "AUTH", message: "Compte connecté via session directe : @\(username)")
    }
    
    /// Met à jour les statistiques après scan
    public func updateAccountStats(likes: Int, videos: Int, reposts: Int, favorites: Int) {
        guard var account = currentAccount else { return }
        account.likesCount = likes
        account.videosCount = videos
        account.repostsCount = reposts
        account.favoritesCount = favorites
        account.lastSyncDate = Date()
        self.currentAccount = account
        self.authStatus = .authenticated(account: account)
        saveAccountMetadata(account)
    }
    
    /// Déconnecte le compte actuel
    public func logout() {
        KeychainManager.shared.clearAll()
        self.currentAccount = nil
        self.authStatus = .unauthenticated
        AppLogger.shared.info(category: "AUTH", message: "Déconnexion effectuée. Identifiants effacés.")
    }
    
    private func saveAccountMetadata(_ account: TikTokAccount) {
        if let data = try? JSONEncoder().encode(account) {
            KeychainManager.shared.save(data: data, forKey: .accountMetadata)
        }
    }
}
