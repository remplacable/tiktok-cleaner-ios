import Foundation

/// Coupe-circuit de sécurité protégeant le compte contre les blocages TikTok massifs.
public actor CircuitBreaker {
    public enum State {
        case closed     // Normal
        case open       // Arrêt d'urgence actif
        case halfOpen   // Test de récupération
    }
    
    private var consecutiveFailures: Int = 0
    private let failureThreshold: Int
    private(set) var state: State = .closed
    
    public init(failureThreshold: Int = 5) {
        self.failureThreshold = failureThreshold
    }
    
    public func recordSuccess() {
        consecutiveFailures = 0
        state = .closed
    }
    
    public func recordFailure() -> Bool {
        consecutiveFailures += 1
        if consecutiveFailures >= failureThreshold {
            state = .open
            AppLogger.shared.error(
                category: "CIRCUIT_BREAKER",
                message: "Coupe-circuit DÉCLENCHÉ : \(consecutiveFailures) échecs consécutifs. Arrêt d'urgence préventif."
            )
            return true // Déclenché
        }
        return false
    }
    
    public func reset() {
        consecutiveFailures = 0
        state = .closed
    }
}
