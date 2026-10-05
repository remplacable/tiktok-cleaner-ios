import Foundation
import Combine

/// Système de journalisation sécurisé avec assainissement des secrets et console in-app.
public final class AppLogger: ObservableObject {
    public static let shared = AppLogger()
    
    @Published public private(set) var logs: [LogEntry] = []
    
    private let maxEntries = 600
    private let queue = DispatchQueue(label: "com.tiktokcleaner.logger", qos: .utility)
    
    private init() {
        info(category: "SYSTEM", message: "TikTok Cleaner v1.0 initialisé - Mode sécurisé actif.")
    }
    
    // MARK: - Méthodes de Log Publiques
    
    public func debug(category: String, message: String) {
        log(level: .debug, category: category, message: message)
    }
    
    public func info(category: String, message: String) {
        log(level: .info, category: category, message: message)
    }
    
    public func warning(category: String, message: String) {
        log(level: .warning, category: category, message: message)
    }
    
    public func error(category: String, message: String) {
        log(level: .error, category: category, message: message)
    }
    
    public func security(category: String, message: String) {
        log(level: .security, category: category, message: message)
    }
    
    // MARK: - Traitement et Assainissement
    
    private func log(level: LogLevel, category: String, message: String) {
        let sanitized = sanitize(message: message)
        let entry = LogEntry(level: level, category: category, message: sanitized)
        
        queue.async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.logs.append(entry)
                if self.logs.count > self.maxEntries {
                    self.logs.removeFirst(self.logs.count - self.maxEntries)
                }
            }
        }
        
        #if DEBUG
        print("[\(entry.formattedTime)] [\(level.rawValue)] [\(category)] \(sanitized)")
        #endif
    }
    
    /// Assainit le message pour éliminer cookies, tokens OAuth, mots de passe et données sensibles.
    private func sanitize(message: String) -> String {
        var clean = message
        
        // Remplacer les tokens sessionid
        let sessionRegex = try? NSRegularExpression(pattern: "sessionid=[a-zA-Z0-9_-]+", options: .caseInsensitive)
        clean = sessionRegex?.stringByReplacingMatches(
            in: clean,
            range: NSRange(clean.startIndex..., in: clean),
            withTemplate: "sessionid=[REDACTED_SECRET]"
        ) ?? clean
        
        // Remplacer les tokens Bearer
        let bearerRegex = try? NSRegularExpression(pattern: "Bearer\\s+[a-zA-Z0-9_.-]+", options: .caseInsensitive)
        clean = bearerRegex?.stringByReplacingMatches(
            in: clean,
            range: NSRange(clean.startIndex..., in: clean),
            withTemplate: "Bearer [REDACTED_TOKEN]"
        ) ?? clean
        
        // Remplacer les CSRF tokens
        let csrfRegex = try? NSRegularExpression(pattern: "csrf[a-zA-Z0-9_-]*=[a-zA-Z0-9_-]+", options: .caseInsensitive)
        clean = csrfRegex?.stringByReplacingMatches(
            in: clean,
            range: NSRange(clean.startIndex..., in: clean),
            withTemplate: "csrf=[REDACTED_CSRF]"
        ) ?? clean
        
        return clean
    }
    
    public func clear() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }
    
    public func exportLogsAsPlainText() -> String {
        logs.map { "[\($0.formattedTime)] [\($0.level.rawValue)] [\($0.category)] \($0.message)" }
            .joined(separator: "\n")
    }
}
