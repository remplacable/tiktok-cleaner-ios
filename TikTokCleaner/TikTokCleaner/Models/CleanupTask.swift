import Foundation

/// Statut d'une tâche de nettoyage individuelle dans la file d'attente.
public enum TaskStatus: String, Codable, Hashable {
    case pending = "En attente"
    case processing = "En cours"
    case completed = "Supprimé"
    case failed = "Échoué"
    case cancelled = "Annulé"
    case retrying = "Nouvel essai"
}

/// Tâche d'opération de nettoyage avec suivi de l'historique et résilience.
public struct CleanupTask: Identifiable, Codable, Hashable {
    public let id: UUID
    public let item: CleanableItem
    public var status: TaskStatus
    public var attempts: Int
    public var maxAttempts: Int
    public var lastError: CleanupError?
    public var startedAt: Date?
    public var completedAt: Date?
    
    public init(
        id: UUID = UUID(),
        item: CleanableItem,
        status: TaskStatus = .pending,
        attempts: Int = 0,
        maxAttempts: Int = 3,
        lastError: CleanupError? = nil,
        startedAt: Date? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.item = item
        self.status = status
        self.attempts = attempts
        self.maxAttempts = maxAttempts
        self.lastError = lastError
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}
