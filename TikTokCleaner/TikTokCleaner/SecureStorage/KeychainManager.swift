import Foundation
import Security

/// Gestionnaire de stockage sécurisé dans le Keychain iOS (Trousseau d'accès).
/// Garantit que les tokens et cookies ne sont jamais stockés dans UserDefaults ou en clair.
public final class KeychainManager {
    public static let shared = KeychainManager()
    
    private let serviceIdentifier = "com.tiktokcleaner.securestorage"
    private let accessGroup: String? = nil
    
    private init() {}
    
    // MARK: - Enregistrement
    
    @discardableResult
    public func save(string: String, forKey key: StorageKey) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data: data, forKey: key)
    }
    
    @discardableResult
    public func save(data: Data, forKey key: StorageKey) -> Bool {
        // Supprimer toute valeur existante au préalable
        delete(forKey: key)
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemAdd(query as CFDictionary, nil)
        let success = (status == errSecSuccess)
        
        if success {
            AppLogger.shared.security(category: "KEYCHAIN", message: "Enregistrement sécurisé réussi pour \(key.rawValue)")
        } else {
            AppLogger.shared.error(category: "KEYCHAIN", message: "Échec enregistrement \(key.rawValue): code \(status)")
        }
        
        return success
    }
    
    // MARK: - Lecture
    
    public func getString(forKey key: StorageKey) -> String? {
        guard let data = getData(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public func getData(forKey key: StorageKey) -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        
        return data
    }
    
    // MARK: - Suppression
    
    @discardableResult
    public func delete(forKey key: StorageKey) -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key.rawValue
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        return (status == errSecSuccess || status == errSecItemNotFound)
    }
    
    public func clearAll() {
        for key in StorageKey.allCases {
            delete(forKey: key)
        }
        AppLogger.shared.security(category: "KEYCHAIN", message: "Toutes les clés du trousseau ont été purgées.")
    }
    
    public func hasCredentials() -> Bool {
        return getString(forKey: .sessionCookie) != nil || getString(forKey: .oauthAccessToken) != nil
    }
}
