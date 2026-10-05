import Foundation
import Combine

/// Modèle de vue pilotant le tableau de bord principal.
public final class DashboardViewModel: ObservableObject {
    @Published public var showScannerSheet = false
    @Published public var showCustomCleanupSheet = false
    @Published public var showQuickCleanupConfirmation = false
    @Published public var showSettingsSheet = false
    @Published public var showLoginSheet = false
    @Published public var showGDPRImportSheet = false
    @Published public var showExecutionView = false
    @Published public var showManualSelectionCategory: CleanupCategory? = nil
    @Published public var showSingleLikeTestSheet = false
    
    public let authManager = AuthManager.shared
    public let scanner = ContentScanner.shared
    public let likeManager = LikeManager.shared
    public let postManager = PostManager.shared
    public let repostManager = RepostManager.shared
    public let favoritesManager = FavoritesManager.shared
    
    public init() {}
    
    public var account: TikTokAccount? {
        authManager.currentAccount
    }
    
    public func startQuickCleanup() {
        // Nettoyage rapide par défaut : les likes et les reposts
        let config = CleanupConfiguration(
            selectedCategories: [.likes, .reposts],
            selectionMode: .all
        )
        CleanupEngine.shared.startCleanup(configuration: config)
        showExecutionView = true
    }
}
