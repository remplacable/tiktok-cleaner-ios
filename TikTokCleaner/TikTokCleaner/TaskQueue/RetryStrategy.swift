import Foundation

/// Stratégie de nouvelle tentative face aux échecs transitoires.
public struct RetryStrategy {
    public let maxAttempts: Int
    public let initialDelay: TimeInterval
    public let multiplier: Double
    public let maxDelay: TimeInterval
    
    public init(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 2.0,
        multiplier: Double = 2.0,
        maxDelay: TimeInterval = 30.0
    ) {
        self.maxAttempts = maxAttempts
        self.initialDelay = initialDelay
        self.multiplier = multiplier
        self.maxDelay = maxDelay
    }
    
    /// Calcule le délai d'attente exponentiel pour un numéro de tentative donné
    public func delay(forAttempt attempt: Int) -> TimeInterval {
        guard attempt > 0 else { return 0 }
        let calculated = initialDelay * pow(multiplier, Double(attempt - 1))
        return min(calculated, maxDelay)
    }
}
