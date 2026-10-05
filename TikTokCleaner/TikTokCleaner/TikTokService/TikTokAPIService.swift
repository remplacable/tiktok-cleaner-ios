import Foundation

/// Façade unifiée pour exécuter les opérations de suppression sur TikTok.
public final class TikTokAPIService {
    public static let shared = TikTokAPIService()
    
    private init() {}
    
    /// Supprime ou annule l'engagement sur un élément selon sa catégorie
    public func deleteItem(_ item: CleanableItem) async throws {
        // Respect du délai adaptatif anti-spam avant chaque requête
        await TikTokRateLimiter.shared.waitBeforeNextRequest(settings: AppSettings.shared.rateLimitSettings)
        
        switch item.category {
        case .likes:
            try await unlike(awemeId: item.id)
            
        case .posts:
            try await deletePost(awemeId: item.id)
            
        case .reposts:
            try await removeRepost(awemeId: item.id)
            
        case .favorites:
            try await unfavorite(awemeId: item.id)
        }
    }
    
    public func unlike(awemeId: String) async throws {
        AppLogger.shared.info(category: "CLEANUP", message: "Suppression du like sur la vidéo \(awemeId)")
        
        if isSimulatedMode {
            try await simulateDelay()
            return
        }
        
        let (success, _) = try await WebKitSessionExecutor.shared.unlikeVideo(awemeId: awemeId)
        if !success {
            throw CleanupError.unknown(message: "Échec de suppression du like par TikTok")
        }
    }
    
    public func unfavorite(awemeId: String) async throws {
        AppLogger.shared.info(category: "CLEANUP", message: "Retrait des favoris pour la vidéo \(awemeId)")
        
        if isSimulatedMode {
            try await simulateDelay()
            return
        }
        
        let success = try await WebKitSessionExecutor.shared.unfavoriteVideo(awemeId: awemeId)
        if !success {
            throw CleanupError.unknown(message: "Échec du retrait du favori")
        }
    }
    
    public func deletePost(awemeId: String) async throws {
        AppLogger.shared.info(category: "CLEANUP", message: "Suppression définitive du post publié \(awemeId)")
        
        if isSimulatedMode {
            try await simulateDelay()
            return
        }
        
        let success = try await WebKitSessionExecutor.shared.deleteVideo(awemeId: awemeId)
        if !success {
            throw CleanupError.unknown(message: "Échec de la suppression de la vidéo")
        }
    }
    
    public func removeRepost(awemeId: String) async throws {
        AppLogger.shared.info(category: "CLEANUP", message: "Annulation de la republication \(awemeId)")
        
        if isSimulatedMode {
            try await simulateDelay()
            return
        }
        
        // Les republications utilisent l'endpoint de partage
        try await TikTokInternalClient.shared.execute(endpoint: .removeRepost(awemeId: awemeId), awemeId: awemeId)
    }
    
    /// Vérifie si la vidéo est encore marquée comme aimée côté TikTok
    public func verifyIfStillLiked(awemeId: String) async throws -> Bool {
        if isSimulatedMode {
            return false // Simule qu'elle a bien été unlikée
        }
        return try await WebKitSessionExecutor.shared.verifyVideoLikeStatus(awemeId: awemeId)
    }
    
    private var isSimulatedMode: Bool {
        AppSettings.shared.isDryRunEnabled || AuthManager.shared.currentAccount?.connectionMethod == .demoAccount
    }
    
    private func simulateDelay() async throws {
        let latency = Double.random(in: 0.2...0.5)
        try await Task.sleep(nanoseconds: UInt64(latency * 1_000_000_000))
    }
}
