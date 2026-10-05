import Foundation
import Combine

/// Gestionnaire de la progression du nettoyage exposé à l'interface utilisateur.
public final class ProgressManager: ObservableObject {
    public static let shared = ProgressManager()
    
    @Published public private(set) var state: CleanupProgressState = CleanupProgressState()
    @Published public private(set) var lastSummary: CleanupSummary?
    
    private init() {}
    
    public func reset(category: CleanupCategory, total: Int) {
        state = CleanupProgressState(
            currentCategory: category,
            totalItems: total,
            processedItems: 0,
            successCount: 0,
            errorCount: 0,
            isPaused: false,
            isCancelled: false,
            isFinished: false,
            startedAt: Date()
        )
        lastSummary = nil
    }
    
    public func recordSuccess() {
        state.processedItems += 1
        state.successCount += 1
    }
    
    public func recordFailure() {
        state.processedItems += 1
        state.errorCount += 1
    }
    
    public func setPaused(_ paused: Bool) {
        state.isPaused = paused
    }
    
    public func setCancelled(_ cancelled: Bool) {
        state.isCancelled = cancelled
    }
    
    public func finish(failedTasks: [CleanupTask]) {
        state.isFinished = true
        let summary = CleanupSummary(
            totalPlanned: state.totalItems,
            successfulCount: state.successCount,
            failedCount: state.errorCount,
            skippedCount: max(0, state.totalItems - state.processedItems),
            startedAt: state.startedAt,
            finishedAt: Date(),
            failedTasks: failedTasks
        )
        self.lastSummary = summary
        AppLogger.shared.info(
            category: "PROGRESS",
            message: "Nettoyage terminé avec \(state.successCount) succès sur \(state.totalItems) éléments."
        )
    }
}
