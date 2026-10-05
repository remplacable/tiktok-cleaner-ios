import Foundation

/// Clés sécurisées stockées dans le trousseau iOS (Keychain).
public enum StorageKey: String, CaseIterable {
    case sessionCookie = "tiktok_session_cookie"
    case csrfToken = "tiktok_csrf_token"
    case webId = "tiktok_web_id"
    case oauthAccessToken = "tiktok_oauth_access_token"
    case oauthRefreshToken = "tiktok_oauth_refresh_token"
    case userSecUid = "tiktok_user_sec_uid"
    case openId = "tiktok_open_id"
    case accountMetadata = "tiktok_account_meta_json"
    
    public var description: String {
        switch self {
        case .sessionCookie: return "Cookie de session chiffré"
        case .csrfToken: return "Jeton anti-forgery CSRF"
        case .webId: return "Identifiant Web TikTok"
        case .oauthAccessToken: return "Jeton d'accès OAuth 2.0"
        case .oauthRefreshToken: return "Jeton de rafraîchissement OAuth"
        case .userSecUid: return "Identifiant sécurisé secUid"
        case .openId: return "Identifiant public OpenID"
        case .accountMetadata: return "Métadonnées du compte local"
        }
    }
}
