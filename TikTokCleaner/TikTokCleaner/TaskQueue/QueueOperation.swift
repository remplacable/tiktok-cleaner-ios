import Foundation

/// Opération élémentaire exécutée par la file d'attente.
public final class QueueOperation: Identifiable {
    public let id: UUID
    public var task: CleanupTask
    public let executeAction: (CleanableItem) async throws -> Void
    
    public init(task: CleanupTask, executeAction: @escaping (CleanableItem) async throws -> Void) {
        self.id = task.id
        self.task = task
        self.executeAction = executeAction
    }
}
