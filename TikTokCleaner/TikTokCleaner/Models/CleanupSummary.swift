import Foundation

/// Bilan détaillé d'une session de nettoyage.
public struct CleanupSummary: Identifiable, Codable {
    public let id: UUID
    public let totalPlanned: Int
    public let successfulCount: Int
    public let failedCount: Int
    public let skippedCount: Int
    public let startedAt: Date
    public let finishedAt: Date
    public let failedTasks: [CleanupTask]
    
    public init(
        id: UUID = UUID(),
        totalPlanned: Int,
        successfulCount: Int,
        failedCount: Int,
        skippedCount: Int,
        startedAt: Date,
        finishedAt: Date,
        failedTasks: [CleanupTask]
    ) {
        self.id = id
        self.totalPlanned = totalPlanned
        self.successfulCount = successfulCount
        self.failedCount = failedCount
        self.skippedCount = skippedCount
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.failedTasks = failedTasks
    }
    
    public var durationSeconds: TimeInterval {
        finishedAt.timeIntervalSince(startedAt)
    }
    
    public var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: durationSeconds) ?? "\(Int(durationSeconds))s"
    }
    
    public var successRate: Double {
        guard totalPlanned > 0 else { return 0 }
        return Double(successfulCount) / Double(totalPlanned)
    }
    
    public var formattedSuccessRate: String {
        let percentage = Int(successRate * 100)
        return "\(percentage)%"
    }
}
