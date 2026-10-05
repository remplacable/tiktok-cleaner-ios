import Foundation

/// État instantané du déroulement d'une session de nettoyage.
public struct CleanupProgressState: Equatable {
    public var currentCategory: CleanupCategory
    public var totalItems: Int
    public var processedItems: Int
    public var successCount: Int
    public var errorCount: Int
    public var isPaused: Bool
    public var isCancelled: Bool
    public var isFinished: Bool
    public var startedAt: Date
    
    public init(
        currentCategory: CleanupCategory = .likes,
        totalItems: Int = 0,
        processedItems: Int = 0,
        successCount: Int = 0,
        errorCount: Int = 0,
        isPaused: Bool = false,
        isCancelled: Bool = false,
        isFinished: Bool = false,
        startedAt: Date = Date()
    ) {
        self.currentCategory = currentCategory
        self.totalItems = totalItems
        self.processedItems = processedItems
        self.successCount = successCount
        self.errorCount = errorCount
        self.isPaused = isPaused
        self.isCancelled = isCancelled
        self.isFinished = isFinished
        self.startedAt = startedAt
    }
    
    public var progressRatio: Double {
        guard totalItems > 0 else { return 0 }
        return min(1.0, Double(processedItems) / Double(totalItems))
    }
    
    public var percentageString: String {
        let percent = Int(progressRatio * 100)
        return "\(percent)%"
    }
    
    public var estimatedRemainingTimeFormatted: String {
        guard processedItems > 0, totalItems > processedItems else { return "--" }
        let elapsed = Date().timeIntervalSince(startedAt)
        let rate = Double(processedItems) / elapsed
        guard rate > 0 else { return "--" }
        let remainingSeconds = Double(totalItems - processedItems) / rate
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: remainingSeconds) ?? "\(Int(remainingSeconds))s"
    }
}
