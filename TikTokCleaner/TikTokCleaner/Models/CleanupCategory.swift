import SwiftUI

/// Catégories de contenu TikTok pouvant être scannées et nettoyées.
public enum CleanupCategory: String, CaseIterable, Identifiable, Codable, Hashable {
    case likes = "likes"
    case posts = "posts"
    case reposts = "reposts"
    case favorites = "favorites"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .likes: return "Likes"
        case .posts: return "Vidéos publiées"
        case .reposts: return "Republications"
        case .favorites: return "Favoris"
        }
    }
    
    public var singularName: String {
        switch self {
        case .likes: return "Like"
        case .posts: return "Vidéo"
        case .reposts: return "Republication"
        case .favorites: return "Favori"
        }
    }
    
    public var iconName: String {
        switch self {
        case .likes: return "heart.fill"
        case .posts: return "film.fill"
        case .reposts: return "arrow.2.squarepath"
        case .favorites: return "star.fill"
        }
    }
    
    public var symbolColor: Color {
        switch self {
        case .likes: return Color(red: 254/255, green: 44/255, blue: 85/255) // TikTok Red
        case .posts: return Color(red: 37/255, green: 244/255, blue: 238/255) // TikTok Cyan
        case .reposts: return Color(red: 168/255, green: 85/255, blue: 247/255) // Purple
        case .favorites: return Color(red: 250/255, green: 204/255, blue: 21/255) // Gold
        }
    }
    
    public var technicalCapability: String {
        switch self {
        case .likes:
            return "Archive GDPR ou Session In-App sécurisée"
        case .posts:
            return "Scan API officielle / Suppression via Session"
        case .reposts:
            return "Archive GDPR ou Session In-App sécurisée"
        case .favorites:
            return "Archive GDPR ou Session In-App sécurisée"
        }
    }
}
