import Foundation

/// Points de terminaison (endpoints) de l'écosystème TikTok.
public enum TikTokEndpoint {
    // Endpoints officiels (TikTok Open API v2)
    case officialUserInfo(fields: String)
    case officialVideoList(cursor: Int, maxCount: Int)
    
    // Endpoints internes TikTok Web (utilisés pour les opérations réelles avec session in-app)
    case unlikeVideo(awemeId: String)
    case unfavoriteVideo(awemeId: String)
    case deleteVideo(awemeId: String)
    case removeRepost(awemeId: String)
    case fetchUserVideos(secUid: String, cursor: Int, count: Int)
    case fetchUserFavorites(secUid: String, cursor: Int, count: Int)
    
    public var url: URL? {
        switch self {
        case .officialUserInfo(let fields):
            return URL(string: "https://open.tiktokapis.com/v2/user/info/?fields=\(fields)")
            
        case .officialVideoList(let cursor, let maxCount):
            return URL(string: "https://open.tiktokapis.com/v2/video/list/?cursor=\(cursor)&max_count=\(maxCount)")
            
        case .unlikeVideo(let awemeId):
            return URL(string: "https://www.tiktok.com/api/commit/item/digg/?aweme_id=\(awemeId)&type=0")
            
        case .unfavoriteVideo(let awemeId):
            return URL(string: "https://www.tiktok.com/api/item/collect/?aweme_id=\(awemeId)&action=0")
            
        case .deleteVideo(let awemeId):
            return URL(string: "https://www.tiktok.com/api/item/delete/?aweme_id=\(awemeId)")
            
        case .removeRepost(let awemeId):
            return URL(string: "https://www.tiktok.com/node/share/item/repost/delete/?aweme_id=\(awemeId)")
            
        case .fetchUserVideos(let secUid, let cursor, let count):
            return URL(string: "https://www.tiktok.com/api/post/item_list/?secUid=\(secUid)&cursor=\(cursor)&count=\(count)")
            
        case .fetchUserFavorites(let secUid, let cursor, let count):
            return URL(string: "https://www.tiktok.com/api/favorite/item_list/?secUid=\(secUid)&cursor=\(cursor)&count=\(count)")
        }
    }
    
    public var httpMethod: String {
        switch self {
        case .officialUserInfo, .officialVideoList, .fetchUserVideos, .fetchUserFavorites:
            return "GET"
        case .unlikeVideo, .unfavoriteVideo, .deleteVideo, .removeRepost:
            return "POST"
        }
    }
}
