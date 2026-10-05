import Foundation

/// Client HTTP pour les requêtes réseau vers TikTok avec en-têtes et cookies sécurisés.
public final class TikTokInternalClient {
    public static let shared = TikTokInternalClient()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20.0
        config.timeoutIntervalForResource = 60.0
        self.session = URLSession(configuration: config)
    }
    
    /// Exécute une action sur un point de terminaison TikTok
    public func execute(endpoint: TikTokEndpoint, awemeId: String) async throws {
        // En mode DryRun (Simulation sécurisée), simuler un traitement réaliste sans appel réseau destructif
        if AppSettings.shared.isDryRunEnabled || AuthManager.shared.currentAccount?.connectionMethod == .demoAccount {
            try await simulateNetworkCall()
            return
        }
        
        guard let url = endpoint.url else {
            throw CleanupError.serverError(statusCode: 400, message: "URL d'action invalide")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        
        // Configuration des en-têtes de sécurité
        request.setValue("https://www.tiktok.com", forHTTPHeaderField: "Referer")
        request.setValue("https://www.tiktok.com", forHTTPHeaderField: "Origin")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        
        // Injection sécurisée des cookies depuis le Keychain
        var cookieParts: [String] = []
        if let sessionCookie = KeychainManager.shared.getString(forKey: .sessionCookie) {
            cookieParts.append("sessionid=\(sessionCookie)")
        }
        if let csrfToken = KeychainManager.shared.getString(forKey: .csrfToken) {
            cookieParts.append("tt_csrf_token=\(csrfToken)")
            request.setValue(csrfToken, forHTTPHeaderField: "X-Secsdk-Csrf-Token")
        }
        if let webId = KeychainManager.shared.getString(forKey: .webId) {
            cookieParts.append("ttwid=\(webId)")
        }
        
        if !cookieParts.isEmpty {
            request.setValue(cookieParts.joined(separator: "; "), forHTTPHeaderField: "Cookie")
        } else {
            AppLogger.shared.warning(category: "NETWORK", message: "Aucun cookie trouvé dans le Keychain pour cette requête.")
        }
        
        AppLogger.shared.debug(category: "NETWORK", message: "Envoi requête \(endpoint.httpMethod) vers \(url.path)")
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            AppLogger.shared.error(category: "NETWORK", message: "Erreur réseau : \(error.localizedDescription)")
            throw CleanupError.networkUnavailable
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CleanupError.invalidResponse
        }
        
        // Analyse du code de retour HTTP
        switch httpResponse.statusCode {
        case 200...299:
            // Vérifier le corps JSON renvoyé par TikTok
            try validateTikTokResponseBody(data: data)
            await TikTokRateLimiter.shared.reportSuccess()
            
        case 429:
            await TikTokRateLimiter.shared.reportRateLimit(retryAfter: 30)
            throw CleanupError.rateLimited(retryAfterSeconds: 30)
            
        case 401, 403:
            throw CleanupError.sessionExpired
            
        case 404:
            throw CleanupError.itemNotFoundOrAlreadyDeleted
            
        default:
            throw CleanupError.serverError(statusCode: httpResponse.statusCode, message: "Code retour \(httpResponse.statusCode)")
        }
    }
    
    /// Valide les codes de statut internes de TikTok
    private func validateTikTokResponseBody(data: Data) throws {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return // Si pas de JSON, considérer le code 200 comme valide
        }
        
        if let statusCode = json["status_code"] as? Int, statusCode != 0 {
            let msg = json["status_msg"] as? String ?? "Erreur TikTok code \(statusCode)"
            
            if statusCode == 10101 || msg.lowercased().contains("verify") || msg.lowercased().contains("captcha") {
                throw CleanupError.captchaRequired
            } else if statusCode == 10202 || msg.lowercased().contains("frequent") || msg.lowercased().contains("rate") {
                throw CleanupError.rateLimited(retryAfterSeconds: 45)
            } else {
                throw CleanupError.serverError(statusCode: statusCode, message: msg)
            }
        }
    }
    
    /// Simule un délai réseau pour le mode démonstration
    private func simulateNetworkCall() async throws {
        let latency = Double.random(in: 0.15...0.45)
        let nanoseconds = UInt64(latency * 1_000_000_000)
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}
