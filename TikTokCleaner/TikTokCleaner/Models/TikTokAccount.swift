import Foundation

/// Méthode d'accès ou d'authentification utilisée pour le compte.
public enum AccountConnectionMethod: String, Codable, Equatable {
    case directSession = "Session In-App (Directe)"
    case officialOAuth = "TikTok Login Kit (Officiel)"
    case importedArchive = "Archive de données GDPR"
    case demoAccount = "Mode Démonstration"
    
    public var description: String {
        switch self {
        case .directSession:
            return "Authentification sécurisée intégrée à l'application. Permet les actions de suppression en local."
        case .officialOAuth:
            return "OAuth 2.0 officiel TikTok. Permet de lire les statistiques et les vidéos publiées."
        case .importedArchive:
            return "Import de l'export JSON officiel TikTok (Paramètres > Compte > Télécharger vos données)."
        case .demoAccount:
            return "Données simulées pour tester les fonctions sans connecter de compte réel."
        }
    }
}

/// Modèle de compte TikTok connecté dans l'application.
public struct TikTokAccount: Identifiable, Codable, Equatable {
    public let id: String
    public var username: String
    public var displayName: String
    public var avatarUrl: URL?
    public var followerCount: Int
    public var followingCount: Int
    public var likesCount: Int
    public var videosCount: Int
    public var repostsCount: Int
    public var favoritesCount: Int
    public var connectionMethod: AccountConnectionMethod
    public var lastSyncDate: Date?
    
    public init(
        id: String = "user_demo",
        username: String = "utilisateur_tiktok",
        displayName: String = "Utilisateur",
        avatarUrl: URL? = nil,
        followerCount: Int = 1420,
        followingCount: Int = 380,
        likesCount: Int = 1284,
        videosCount: Int = 42,
        repostsCount: Int = 316,
        favoritesCount: Int = 892,
        connectionMethod: AccountConnectionMethod = .demoAccount,
        lastSyncDate: Date? = Date()
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.likesCount = likesCount
        self.videosCount = videosCount
        self.repostsCount = repostsCount
        self.favoritesCount = favoritesCount
        self.connectionMethod = connectionMethod
        self.lastSyncDate = lastSyncDate
    }
    
    public var totalCleanableItems: Int {
        likesCount + videosCount + repostsCount + favoritesCount
    }
}
