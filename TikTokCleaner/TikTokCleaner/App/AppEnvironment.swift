import SwiftUI

/// Environnement global et injection des singletons applicatifs.
public final class AppEnvironment: ObservableObject {
    public static let shared = AppEnvironment()
    
    public let authManager = AuthManager.shared
    public let cleanupEngine = CleanupEngine.shared
    public let contentScanner = ContentScanner.shared
    public let appSettings = AppSettings.shared
    public let logger = AppLogger.shared
    
    private init() {
        logger.info(category: "APP", message: "Initialisation de l'environnement TikTok Cleaner.")
    }
}
