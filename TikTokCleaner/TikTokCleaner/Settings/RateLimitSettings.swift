import Foundation

/// Configuration du limiteur de débit et du rythme d'exécution.
public struct RateLimitSettings: Codable, Equatable {
    /// Délai moyen entre chaque requête de suppression (secondes)
    public var requestIntervalSeconds: Double
    
    /// Fluctuation aléatoire (jitter) pour imiter un comportement humain naturel
    public var jitterRangeSeconds: Double
    
    /// Nombre d'actions maximal avant d'imposer une pause prolongée de sécurité
    public var burstSizeBeforeRest: Int
    
    /// Durée de la pause de sécurité (secondes)
    public var restDurationSeconds: Double
    
    /// Nombre maximal d'essais en cas d'erreur transitoire
    public var maxRetriesPerItem: Int
    
    public init(
        requestIntervalSeconds: Double = 3.0,
        jitterRangeSeconds: Double = 1.5,
        burstSizeBeforeRest: Int = 25,
        restDurationSeconds: Double = 15.0,
        maxRetriesPerItem: Int = 3
    ) {
        self.requestIntervalSeconds = requestIntervalSeconds
        self.jitterRangeSeconds = jitterRangeSeconds
        self.burstSizeBeforeRest = burstSizeBeforeRest
        self.restDurationSeconds = restDurationSeconds
        self.maxRetriesPerItem = maxRetriesPerItem
    }
    
    /// Calcule un délai réaliste avec gigue aléatoire
    public var nextAdaptiveDelay: TimeInterval {
        let jitter = Double.random(in: -jitterRangeSeconds...jitterRangeSeconds)
        return max(1.0, requestIntervalSeconds + jitter)
    }
}
