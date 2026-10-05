import Foundation

/// Service pour l'API officielle TikTok Login Kit (OAuth 2.0).
/// Permet la récupération des statistiques de base et de la liste officielle des vidéos publiques.
public final class TikTokOAuthService {
    public static let shared = TikTokOAuthService()
    
    // Configuration par défaut (peut être configurée dans les paramètres ou variables d'environnement)
    public var clientKey: String = "awxxxxxxxxxxxxxx"
    public var redirectUri: String = "tiktokcleaner://oauth"
    public var scopes: [String] = ["user.info.basic", "user.info.stats", "video.list"]
    
    private init() {}
    
    /// Construit l'URL d'autorisation OAuth 2.0 officielle
    public func buildAuthorizationUrl(csrfState: String = UUID().uuidString) -> URL? {
        var components = URLComponents(string: "https://www.tiktok.com/v2/auth/authorize/")
        components?.queryItems = [
            URLQueryItem(name: "client_key", value: clientKey),
            URLQueryItem(name: "scope", value: scopes.joined(separator: ",")),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "state", value: csrfState)
        ]
        return components?.url
    }
    
    /// Échange un code d'autorisation contre un access token officiel
    public func exchangeCodeForToken(code: String, clientSecret: String) async throws -> (accessToken: String, openId: String) {
        guard let url = URL(string: "https://open.tiktokapis.com/v2/oauth/token/") else {
            throw CleanupError.serverError(statusCode: 400, message: "URL OAuth invalide")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Cache-Control")
        
        let bodyParameters = [
            "client_key": clientKey,
            "client_secret": clientSecret,
            "code": code,
            "grant_type": "authorization_code",
            "redirect_uri": redirectUri
        ]
        
        let bodyString = bodyParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        AppLogger.shared.info(category: "OAUTH", message: "Échange du code d'autorisation OAuth en cours...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CleanupError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw CleanupError.serverError(statusCode: httpResponse.statusCode, message: "Échec token OAuth")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataDict = json["data"] as? [String: Any],
              let token = dataDict["access_token"] as? String,
              let openId = dataDict["open_id"] as? String else {
            throw CleanupError.invalidResponse
        }
        
        // Sauvegarder dans le Keychain
        KeychainManager.shared.save(string: token, forKey: .oauthAccessToken)
        KeychainManager.shared.save(string: openId, forKey: .openId)
        
        AppLogger.shared.security(category: "OAUTH", message: "Token OAuth 2.0 officiel stocké de manière sécurisée.")
        return (token, openId)
    }
    
    /// Récupère le profil et les statistiques via l'API officielle
    public func fetchUserProfile(accessToken: String) async throws -> TikTokAccount {
        let fields = "open_id,union_id,avatar_url,display_name,follower_count,following_count,likes_count,video_count"
        guard let url = URL(string: "https://open.tiktokapis.com/v2/user/info/?fields=\(fields)") else {
            throw CleanupError.serverError(statusCode: 400, message: "URL invalide")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw CleanupError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: "Échec récupération profil")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataDict = json["data"] as? [String: Any],
              let userDict = dataDict["user"] as? [String: Any] else {
            throw CleanupError.invalidResponse
        }
        
        let openId = userDict["open_id"] as? String ?? "unknown"
        let displayName = userDict["display_name"] as? String ?? "Utilisateur TikTok"
        let avatarUrlStr = userDict["avatar_url"] as? String
        let avatarUrl = avatarUrlStr != nil ? URL(string: avatarUrlStr!) : nil
        let followerCount = userDict["follower_count"] as? Int ?? 0
        let followingCount = userDict["following_count"] as? Int ?? 0
        let likesCount = userDict["likes_count"] as? Int ?? 0
        let videoCount = userDict["video_count"] as? Int ?? 0
        
        return TikTokAccount(
            id: openId,
            username: displayName.lowercased().replacingOccurrences(of: " ", with: "_"),
            displayName: displayName,
            avatarUrl: avatarUrl,
            followerCount: followerCount,
            followingCount: followingCount,
            likesCount: likesCount,
            videosCount: videoCount,
            repostsCount: 0, // Non exposé par l'API officielle
            favoritesCount: 0, // Non exposé par l'API officielle
            connectionMethod: .officialOAuth,
            lastSyncDate: Date()
        )
    }
}
