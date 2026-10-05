import Foundation
import Combine

/// File d'attente résiliente gérant l'ordonnancement, les pauses, l'annulation et les reprises.
public final class TaskQueue: ObservableObject {
    public static let shared = TaskQueue()
    
    public enum QueueState: Equatable {
        case idle
        case running
        case paused
        case cancelled
        case completed
    }
    
    @Published public private(set) var state: QueueState = .idle
    @Published public private(set) var tasks: [CleanupTask] = []
    @Published public private(set) var currentTaskIndex: Int = 0
    @Published public private(set) var completedCount: Int = 0
    @Published public private(set) var failedCount: Int = 0
    
    private var isProcessing = false
    private var shouldPause = false
    private var shouldCancel = false
    private let retryStrategy = RetryStrategy()
    
    private init() {}
    
    public func loadTasks(items: [CleanableItem]) {
        self.tasks = items.map { CleanupTask(item: $0) }
        self.currentTaskIndex = 0
        self.completedCount = 0
        self.failedCount = 0
        self.state = .idle
        self.shouldPause = false
        self.shouldCancel = false
        AppLogger.shared.info(category: "QUEUE", message: "File d'attente chargée avec \(items.count) éléments.")
    }
    
    public func start() async {
        guard state != .running else { return }
        state = .running
        shouldPause = false
        shouldCancel = false
        AppLogger.shared.info(category: "QUEUE", message: "Exécution de la file d'attente démarrée.")
        
        while currentTaskIndex < tasks.count {
            if shouldCancel {
                state = .cancelled
                AppLogger.shared.warning(category: "QUEUE", message: "File d'attente annulée par l'utilisateur.")
                return
            }
            
            if shouldPause {
                state = .paused
                AppLogger.shared.info(category: "QUEUE", message: "File d'attente en pause.")
                return
            }
            
            var task = tasks[currentTaskIndex]
            task.status = .processing
            task.startedAt = Date()
            updateTask(task, at: currentTaskIndex)
            
            // Exécution avec stratégie de résilience
            let success = await executeWithRetry(task: &task)
            
            if success {
                task.status = .completed
                task.completedAt = Date()
                completedCount += 1
            } else {
                task.status = .failed
                failedCount += 1
            }
            
            updateTask(task, at: currentTaskIndex)
            currentTaskIndex += 1
        }
        
        state = .completed
        AppLogger.shared.info(category: "QUEUE", message: "Toutes les tâches de la file ont été traitées. Succès: \(completedCount), Échecs: \(failedCount).")
    }
    
    public func pause() {
        shouldPause = true
    }
    
    public func resume() {
        if state == .paused {
            Task {
                await start()
            }
        }
    }
    
    public func cancel() {
        shouldCancel = true
        shouldPause = false
    }
    
    private func executeWithRetry(task: inout CleanupTask) async -> Bool {
        while task.attempts < task.maxAttempts {
            task.attempts += 1
            
            do {
                try await TikTokAPIService.shared.deleteItem(task.item)
                return true
            } catch let error as CleanupError {
                task.lastError = error
                AppLogger.shared.error(
                    category: "QUEUE",
                    message: "Échec suppression \(task.item.id) (Tentative \(task.attempts)/\(task.maxAttempts)): \(error.title)"
                )
                
                if !error.isRetryable || task.attempts >= task.maxAttempts {
                    return false
                }
                
                // Backoff exponentiel
                let delay = retryStrategy.delay(forAttempt: task.attempts)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                task.status = .retrying
                
            } catch {
                let err = CleanupError.unknown(message: error.localizedDescription)
                task.lastError = err
                return false
            }
        }
        return false
    }
    
    private func updateTask(_ task: CleanupTask, at index: Int) {
        DispatchQueue.main.async {
            if index < self.tasks.count {
                self.tasks[index] = task
            }
        }
    }
    
    public var failedTasks: [CleanupTask] {
        tasks.filter { $0.status == .failed }
    }
}
