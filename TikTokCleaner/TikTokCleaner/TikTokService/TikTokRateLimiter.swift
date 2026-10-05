import Foundation

/// Limiteur de débit adaptatif pour respecter les politiques anti-spam de TikTok.
public actor TikTokRateLimiter {
    public static let shared = TikTokRateLimiter()
    
    private var actionCount: Int = 0
    private var lastRequestTime: Date = Date.distantPast
    private var currentBackoffMultiplier: Double = 1.0
    
    private init() {}
    
    /// Attend le temps nécessaire avant d'autoriser la prochaine requête
    public func waitBeforeNextRequest(settings: RateLimitSettings) async {
        let now = Date()
        let timeSinceLast = now.timeIntervalSince(lastRequestTime)
        
        var delay = settings.nextAdaptiveDelay * currentBackoffMultiplier
        
        // Vérifier si un palier de repos (burst) est atteint
        actionCount += 1
        if actionCount >= settings.burstSizeBeforeRest {
            AppLogger.shared.warning(
                category: "RATE_LIMIT",
                message: "Palier de \(actionCount) actions atteint. Pause de sécurité de \(settings.restDurationSeconds)s..."
            )
            delay += settings.restDurationSeconds
            actionCount = 0
        }
        
        if timeSinceLast < delay {
            let sleepTime = delay - timeSinceLast
            let nanoseconds = UInt64(sleepTime * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
        }
        
        lastRequestTime = Date()
    }
    
    /// Signale une limitation de débit (HTTP 429) et augmente le backoff
    public func reportRateLimit(retryAfter: Int = 30) {
        currentBackoffMultiplier = min(currentBackoffMultiplier * 1.5, 4.0)
        AppLogger.shared.warning(
            category: "RATE_LIMIT",
            message: "Signalement de rate limit TikTok. Multiplicateur de délai porté à \(currentBackoffMultiplier)x."
        )
    }
    
    /// Réinitialise le multiplicateur après des requêtes réussies consécutives
    public func reportSuccess() {
        if currentBackoffMultiplier > 1.0 {
            currentBackoffMultiplier = max(1.0, currentBackoffMultiplier - 0.2)
        }
    }
    
    public func reset() {
        actionCount = 0
        lastRequestTime = Date.distantPast
        currentBackoffMultiplier = 1.0
    }
}
