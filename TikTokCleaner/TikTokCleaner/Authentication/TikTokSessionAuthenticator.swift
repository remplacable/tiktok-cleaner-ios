import Foundation
import WebKit

/// Authentificateur de session interne TikTok.
/// Permet à l'utilisateur de se connecter directement depuis l'application via WKWebView sécurisé,
/// extrait automatiquement les cookies de session (sessionid, tt_csrf_token) et les place dans le Keychain.
/// Ne redirige jamais vers Safari ni Chrome.
public final class TikTokSessionAuthenticator: NSObject {
    public static let shared = TikTokSessionAuthenticator()
    
    private override init() {
        super.init()
    }
    
    /// Analyse les cookies du stockage HTTP pour extraire la session active TikTok
    public func extractSessionCookies(from store: WKHTTPCookieStore) async -> (sessionId: String?, csrfToken: String?, webId: String?) {
        let cookies = await store.allCookies()
        var session: String?
        var csrf: String?
        var webId: String?
        
        for cookie in cookies {
            if cookie.name == "sessionid" || cookie.name == "sessionid_ss" {
                session = cookie.value
            } else if cookie.name == "tt_csrf_token" || cookie.name.contains("csrf") {
                csrf = cookie.value
            } else if cookie.name == "ttwid" || cookie.name == "web_id" {
                webId = cookie.value
            }
        }
        
        if let s = session {
            KeychainManager.shared.save(string: s, forKey: .sessionCookie)
            AppLogger.shared.security(category: "AUTH", message: "Cookie de session extrait avec succès et protégé dans le Keychain.")
        }
        if let c = csrf {
            KeychainManager.shared.save(string: c, forKey: .csrfToken)
        }
        if let w = webId {
            KeychainManager.shared.save(string: w, forKey: .webId)
        }
        
        return (session, csrf, webId)
    }
    
    /// Vérifie si une session active est stockée dans le Keychain
    public func hasActiveSession() -> Bool {
        return KeychainManager.shared.getString(forKey: .sessionCookie) != nil
    }
    
    /// Déconnexion et purge des cookies de session
    public func logout(from store: WKHTTPCookieStore? = nil) async {
        KeychainManager.shared.delete(forKey: .sessionCookie)
        KeychainManager.shared.delete(forKey: .csrfToken)
        KeychainManager.shared.delete(forKey: .webId)
        KeychainManager.shared.delete(forKey: .userSecUid)
        
        if let store = store {
            let cookies = await store.allCookies()
            for cookie in cookies where cookie.domain.contains("tiktok.com") {
                await store.delete(cookie)
            }
        }
        
        AppLogger.shared.info(category: "AUTH", message: "Session TikTok révoquée et nettoyée.")
    }
}
