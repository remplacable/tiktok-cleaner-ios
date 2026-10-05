import Foundation

/// Structure de décodage des exports officiels de données TikTok (format JSON GDPR).
public struct GDPRTikTokExport: Codable {
    public let activity: GDPRActivity?
    public let video: GDPRVideoSection?
    
    enum CodingKeys: String, CodingKey {
        case activity = "Activity"
        case video = "Video"
    }
}

public struct GDPRActivity: Codable {
    public let likeList: GDPRLikeListWrapper?
    public let favoriteVideos: GDPRFavoriteVideosWrapper?
    public let shareHistory: GDPRShareHistoryWrapper?
    
    enum CodingKeys: String, CodingKey {
        case likeList = "Like List"
        case favoriteVideos = "Favorite Videos"
        case shareHistory = "Share History"
    }
}

public struct GDPRLikeListWrapper: Codable {
    public let itemFavoriteList: [GDPRLikeItem]?
    
    enum CodingKeys: String, CodingKey {
        case itemFavoriteList = "ItemFavoriteList"
    }
}

public struct GDPRLikeItem: Codable {
    public let date: String
    public let link: String
}

public struct GDPRFavoriteVideosWrapper: Codable {
    public let favoriteVideoList: [GDPRFavoriteItem]?
    
    enum CodingKeys: String, CodingKey {
        case favoriteVideoList = "FavoriteVideoList"
    }
}

public struct GDPRFavoriteItem: Codable {
    public let date: String
    public let link: String
}

public struct GDPRShareHistoryWrapper: Codable {
    public let shareHistoryList: [GDPRShareItem]?
    
    enum CodingKeys: String, CodingKey {
        case shareHistoryList = "ShareHistoryList"
    }
}

public struct GDPRShareItem: Codable {
    public let date: String
    public let link: String
}

public struct GDPRVideoSection: Codable {
    public let videos: GDPRVideoListWrapper?
    
    enum CodingKeys: String, CodingKey {
        case videos = "Videos"
    }
}

public struct GDPRVideoListWrapper: Codable {
    public let videoList: [GDPRVideoItem]?
    
    enum CodingKeys: String, CodingKey {
        case videoList = "VideoList"
    }
}

public struct GDPRVideoItem: Codable {
    public let date: String
    public let videoLink: String?
    public let likes: String?
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case videoLink = "video_link"
        case likes = "likes"
    }
}
