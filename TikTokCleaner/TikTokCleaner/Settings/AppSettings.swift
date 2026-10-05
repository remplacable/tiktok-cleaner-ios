import Foundation
import Combine

/// Réglages globaux de l'application (paramètres non sensibles).
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()
    
    private enum Keys {
        static let isDryRunEnabled = "isDryRunEnabled"
        static let autoRetryFailed = "autoRetryFailed"
        static let showThumbnails = "showThumbnails"
        static let hapticFeedbackEnabled = "hapticFeedbackEnabled"
        static let rateLimitSettings = "rateLimitSettings"
        static let autoPauseOnRateLimit = "autoPauseOnRateLimit"
    }
    
    @Published public var isDryRunEnabled: Bool {
        didSet { UserDefaults.standard.set(isDryRunEnabled, forKey: Keys.isDryRunEnabled) }
    }
    
    @Published public var autoRetryFailed: Bool {
        didSet { UserDefaults.standard.set(autoRetryFailed, forKey: Keys.autoRetryFailed) }
    }
    
    @Published public var showThumbnails: Bool {
        didSet { UserDefaults.standard.set(showThumbnails, forKey: Keys.showThumbnails) }
    }
    
    @Published public var hapticFeedbackEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticFeedbackEnabled, forKey: Keys.hapticFeedbackEnabled) }
    }
    
    @Published public var autoPauseOnRateLimit: Bool {
        didSet { UserDefaults.standard.set(autoPauseOnRateLimit, forKey: Keys.autoPauseOnRateLimit) }
    }
    
    @Published public var rateLimitSettings: RateLimitSettings {
        didSet {
            if let data = try? JSONEncoder().encode(rateLimitSettings) {
                UserDefaults.standard.set(data, forKey: Keys.rateLimitSettings)
            }
        }
    }
    
    private init() {
        self.isDryRunEnabled = UserDefaults.standard.bool(forKey: Keys.isDryRunEnabled)
        self.autoRetryFailed = UserDefaults.standard.object(forKey: Keys.autoRetryFailed) as? Bool ?? true
        self.showThumbnails = UserDefaults.standard.object(forKey: Keys.showThumbnails) as? Bool ?? true
        self.hapticFeedbackEnabled = UserDefaults.standard.object(forKey: Keys.hapticFeedbackEnabled) as? Bool ?? true
        self.autoPauseOnRateLimit = UserDefaults.standard.object(forKey: Keys.autoPauseOnRateLimit) as? Bool ?? true
        
        if let data = UserDefaults.standard.data(forKey: Keys.rateLimitSettings),
           let decoded = try? JSONDecoder().decode(RateLimitSettings.self, from: data) {
            self.rateLimitSettings = decoded
        } else {
            self.rateLimitSettings = RateLimitSettings()
        }
    }
    
    public func resetToDefaults() {
        isDryRunEnabled = false
        autoRetryFailed = true
        showThumbnails = true
        hapticFeedbackEnabled = true
        autoPauseOnRateLimit = true
        rateLimitSettings = RateLimitSettings()
    }
}
