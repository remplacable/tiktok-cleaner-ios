import Foundation

/// États d'authentification du compte utilisateur.
public enum AuthStatus: Equatable {
    case unauthenticated
    case authenticating(step: String)
    case authenticated(account: TikTokAccount)
    case error(message: String)
    
    public var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }
}
