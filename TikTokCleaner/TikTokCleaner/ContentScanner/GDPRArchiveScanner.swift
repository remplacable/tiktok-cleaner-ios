import Foundation

/// Scanner d'archive de données TikTok officiel (format JSON RGPD).
/// Permet de charger instantanément et hors ligne des dizaines de milliers d'éléments
/// sans solliciter l'API ni risquer de blocage anti-bot.
public final class GDPRArchiveScanner {
    public static let shared = GDPRArchiveScanner()
    
    private init() {}
    
    /// Parse les données JSON d'un export TikTok
    public func parseArchive(jsonData: Data) throws -> [CleanableItem] {
        let decoder = JSONDecoder()
        var items: [CleanableItem] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        do {
            let export = try decoder.decode(GDPRTikTokExport.self, from: jsonData)
            
            // 1. Likes
            if let likeItems = export.activity?.likeList?.itemFavoriteList {
                for item in likeItems {
                    let id = extractAwemeId(from: item.link)
                    let date = dateFormatter.date(from: item.date) ?? Date()
                    let cleanable = CleanableItem(
                        id: id,
                        category: .likes,
                        title: "Vidéo likée le \(item.date)",
                        timestamp: date,
                        videoUrl: URL(string: item.link)
                    )
                    items.append(cleanable)
                }
            }
            
            // 2. Favoris
            if let favItems = export.activity?.favoriteVideos?.favoriteVideoList {
                for item in favItems {
                    let id = extractAwemeId(from: item.link)
                    let date = dateFormatter.date(from: item.date) ?? Date()
                    let cleanable = CleanableItem(
                        id: id,
                        category: .favorites,
                        title: "Favori enregistré",
                        timestamp: date,
                        videoUrl: URL(string: item.link)
                    )
                    items.append(cleanable)
                }
            }
            
            // 3. Republications
            if let shareItems = export.activity?.shareHistory?.shareHistoryList {
                for item in shareItems {
                    let id = extractAwemeId(from: item.link)
                    let date = dateFormatter.date(from: item.date) ?? Date()
                    let cleanable = CleanableItem(
                        id: id,
                        category: .reposts,
                        title: "Republication partagée",
                        timestamp: date,
                        videoUrl: URL(string: item.link)
                    )
                    items.append(cleanable)
                }
            }
            
            // 4. Vidéos publiées
            if let videoList = export.video?.videos?.videoList {
                for item in videoList {
                    let link = item.videoLink ?? ""
                    let id = extractAwemeId(from: link)
                    let date = dateFormatter.date(from: item.date) ?? Date()
                    let cleanable = CleanableItem(
                        id: id,
                        category: .posts,
                        title: "Publication originale",
                        timestamp: date,
                        videoUrl: URL(string: link),
                        likeCount: Int(item.likes ?? "0")
                    )
                    items.append(cleanable)
                }
            }
            
            AppLogger.shared.info(category: "SCANNER", message: "Archive JSON analysée avec succès: \(items.count) éléments trouvés.")
            return items
            
        } catch {
            AppLogger.shared.error(category: "SCANNER", message: "Erreur décodage JSON RGPD : \(error.localizedDescription)")
            throw CleanupError.invalidResponse
        }
    }
    
    /// Extrait l'identifiant numérique de la vidéo depuis une URL TikTok
    public func extractAwemeId(from urlString: String) -> String {
        // Formats typiques :
        // https://www.tiktok.com/@user/video/7234567890123456789
        // https://vm.tiktok.com/ZMxxxxxx/
        let components = urlString.split(separator: "/")
        if let videoIndex = components.firstIndex(of: "video"), videoIndex + 1 < components.count {
            let candidate = String(components[videoIndex + 1])
            let numericPart = candidate.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if !numericPart.isEmpty {
                return numericPart
            }
        }
        
        let digits = urlString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if digits.count >= 10 {
            return digits
        }
        
        return UUID().uuidString
    }
}
