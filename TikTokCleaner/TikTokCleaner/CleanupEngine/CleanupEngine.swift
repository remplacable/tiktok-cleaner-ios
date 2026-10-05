import Foundation
import Combine

/// Moteur principal d'exécution et de coordination du nettoyage TikTok.
public final class CleanupEngine: ObservableObject {
    public static let shared = CleanupEngine()
    
    @Published public private(set) var isRunning: Bool = false
    @Published public private(set) var isPaused: Bool = false
    @Published public private(set) var currentItemBeingDeleted: CleanableItem?
    
    private let taskQueue = TaskQueue.shared
    private let progressManager = ProgressManager.shared
    private let circuitBreaker = CircuitBreaker()
    private var cleanupTask: Task<Void, Never>?
    
    private init() {}
    
    /// Démarre un nettoyage basé sur une configuration spécifique
    public func startCleanup(configuration: CleanupConfiguration) {
        guard !isRunning else { return }
        
        // 1. Filtrer les éléments selon la configuration
        let itemsToClean = resolveItemsToClean(configuration: configuration)
        guard !itemsToClean.isEmpty else {
            AppLogger.shared.warning(category: "ENGINE", message: "Aucun élément sélectionné pour le nettoyage.")
            return
        }
        
        let primaryCategory = configuration.selectedCategories.first ?? .likes
        progressManager.reset(category: primaryCategory, total: itemsToClean.count)
        taskQueue.loadTasks(items: itemsToClean)
        
        isRunning = true
        isPaused = false
        
        AppLogger.shared.info(
            category: "ENGINE",
            message: "Lancement du nettoyage : \(itemsToClean.count) éléments ciblés sur les catégories \(configuration.selectedCategories.map { $0.displayName }.joined(separator: ", "))."
        )
        
        cleanupTask = Task { @MainActor in
            await self.runExecutionLoop()
        }
    }
    
    /// Boucle d'exécution continue avec synchronisation des statuts
    @MainActor
    private func runExecutionLoop() async {
        await taskQueue.start()
        
        // Surveillance et synchronisation de la progression
        for task in taskQueue.tasks {
            if task.status == .completed {
                progressManager.recordSuccess()
                removeCleanedItemFromLocalManager(task.item)
            } else if task.status == .failed {
                progressManager.recordFailure()
            }
        }
        
        // Bilan et finalisation
        progressManager.finish(failedTasks: taskQueue.failedTasks)
        isRunning = false
        isPaused = false
        currentItemBeingDeleted = nil
        
        // Mise à jour des compteurs du compte connecté
        syncAccountCountersAfterCleanup()
    }
    
    public func pause() {
        guard isRunning, !isPaused else { return }
        taskQueue.pause()
        progressManager.setPaused(true)
        isPaused = true
        AppLogger.shared.info(category: "ENGINE", message: "Nettoyage mis en pause.")
    }
    
    public func resume() {
        guard isRunning, isPaused else { return }
        progressManager.setPaused(false)
        isPaused = false
        taskQueue.resume()
        AppLogger.shared.info(category: "ENGINE", message: "Nettoyage repris.")
    }
    
    public func cancel() {
        guard isRunning else { return }
        taskQueue.cancel()
        cleanupTask?.cancel()
        progressManager.setCancelled(true)
        progressManager.finish(failedTasks: taskQueue.failedTasks)
        isRunning = false
        isPaused = false
        currentItemBeingDeleted = nil
        AppLogger.shared.warning(category: "ENGINE", message: "Nettoyage interrompu manuellement.")
    }
    
    /// Résout la liste concrète des éléments à traiter selon le filtre choisi
    private func resolveItemsToClean(configuration: CleanupConfiguration) -> [CleanableItem] {
        if let custom = configuration.customSelectedItems, !custom.isEmpty {
            return custom
        }
        
        var aggregated: [CleanableItem] = []
        
        if configuration.selectedCategories.contains(.likes) {
            aggregated.append(contentsOf: LikeManager.shared.items)
        }
        if configuration.selectedCategories.contains(.posts) {
            aggregated.append(contentsOf: PostManager.shared.items)
        }
        if configuration.selectedCategories.contains(.reposts) {
            aggregated.append(contentsOf: RepostManager.shared.items)
        }
        if configuration.selectedCategories.contains(.favorites) {
            aggregated.append(contentsOf: FavoritesManager.shared.items)
        }
        
        switch configuration.selectionMode {
        case .all:
            return aggregated
            
        case .manualSelection:
            let selectedOnly = aggregated.filter { $0.isSelected }
            return selectedOnly.isEmpty ? aggregated : selectedOnly
            
        case .byDate(let targetDate):
            let calendar = Calendar.current
            return aggregated.filter { calendar.isDate($0.timestamp, inSameDayAs: targetDate) }
            
        case .byPeriod(let start, let end):
            return aggregated.filter { $0.timestamp >= start && $0.timestamp <= end }
        }
    }
    
    private func removeCleanedItemFromLocalManager(_ item: CleanableItem) {
        switch item.category {
        case .likes:
            LikeManager.shared.removeItem(withId: item.id)
        case .posts:
            PostManager.shared.removeItem(withId: item.id)
        case .reposts:
            RepostManager.shared.removeItem(withId: item.id)
        case .favorites:
            FavoritesManager.shared.removeItem(withId: item.id)
        }
    }
    
    private func syncAccountCountersAfterCleanup() {
        AuthManager.shared.updateAccountStats(
            likes: LikeManager.shared.totalCount,
            videos: PostManager.shared.totalCount,
            reposts: RepostManager.shared.totalCount,
            favorites: FavoritesManager.shared.totalCount
        )
    }
}
