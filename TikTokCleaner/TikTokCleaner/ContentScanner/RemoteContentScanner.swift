import Foundation

/// Scanner de contenu en ligne via session active ou API officielle.
public final class RemoteContentScanner {
    public static let shared = RemoteContentScanner()
    
    private init() {}
    
    /// Scanne les vidéos publiées via l'API officielle TikTok
    public func scanOfficialPublishedVideos(accessToken: String, count: Int = 50) async throws -> [CleanableItem] {
        guard let url = TikTokEndpoint.officialVideoList(cursor: 0, maxCount: min(count, 50)).url else {
            throw CleanupError.serverError(statusCode: 400, message: "URL invalide")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw CleanupError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: "Échec récupération vidéos")
        }
        
        var items: [CleanableItem] = []
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataDict = json["data"] as? [String: Any],
           let videoList = dataDict["videos"] as? [[String: Any]] {
            
            for v in videoList {
                let id = v["id"] as? String ?? UUID().uuidString
                let title = v["title"] as? String ?? "Vidéo TikTok"
                let createTime = v["create_time"] as? TimeInterval ?? Date().timeIntervalSince1970
                let shareUrl = v["share_url"] as? String
                let coverUrl = v["cover_image_url"] as? String
                let likeCount = v["like_count"] as? Int
                let viewCount = v["view_count"] as? Int
                
                let item = CleanableItem(
                    id: id,
                    category: .posts,
                    title: title,
                    timestamp: Date(timeIntervalSince1970: createTime),
                    videoUrl: shareUrl != nil ? URL(string: shareUrl!) : nil,
                    thumbnailUrl: coverUrl != nil ? URL(string: coverUrl!) : nil,
                    viewCount: viewCount,
                    likeCount: likeCount
                )
                items.append(item)
            }
        }
        
        return items
    }
    
    /// Génère un ensemble de données haute fidélité pour le mode Démonstration
    public func generateHighFidelityDemoDataset() -> [CleanableItem] {
        var items: [CleanableItem] = []
        let now = Date()
        let calendar = Calendar.current
        
        // 1. Likes (1 284 éléments simulés, on en génère un échantillon représentatif de 120 affichables + stats totales)
        for i in 1...120 {
            let daysAgo = Double(i) * 1.5
            let date = now.addingTimeInterval(-daysAgo * 86400)
            items.append(CleanableItem(
                id: "7234\(800000 + i)",
                category: .likes,
                title: "Vidéo tendance #\(i)",
                authorUsername: "@creator_\(i % 15)",
                timestamp: date,
                videoUrl: URL(string: "https://www.tiktok.com/@creator/video/7234\(800000 + i)"),
                thumbnailUrl: URL(string: "https://picsum.photos/seed/\(i + 100)/200/300"),
                likeCount: Int.random(in: 1200...450000)
            ))
        }
        
        // 2. Vidéos publiées (42 vidéos)
        for i in 1...42 {
            let daysAgo = Double(i) * 4.2
            let date = now.addingTimeInterval(-daysAgo * 86400)
            items.append(CleanableItem(
                id: "7235\(900000 + i)",
                category: .posts,
                title: "Mon vlog du weekend #\(i)",
                authorUsername: "@mon_compte",
                timestamp: date,
                videoUrl: URL(string: "https://www.tiktok.com/@mon_compte/video/7235\(900000 + i)"),
                thumbnailUrl: URL(string: "https://picsum.photos/seed/\(i + 300)/200/300"),
                viewCount: Int.random(in: 450...18500),
                likeCount: Int.random(in: 32...1420)
            ))
        }
        
        // 3. Republications (316 éléments, 80 affichables)
        for i in 1...80 {
            let daysAgo = Double(i) * 2.1
            let date = now.addingTimeInterval(-daysAgo * 86400)
            items.append(CleanableItem(
                id: "7236\(100000 + i)",
                category: .reposts,
                title: "Republication : astuce tech #\(i)",
                authorUsername: "@tech_tips_\(i % 10)",
                timestamp: date,
                videoUrl: URL(string: "https://www.tiktok.com/@tech_tips/video/7236\(100000 + i)"),
                thumbnailUrl: URL(string: "https://picsum.photos/seed/\(i + 500)/200/300"),
                likeCount: Int.random(in: 5000...95000)
            ))
        }
        
        // 4. Favoris (892 éléments, 90 affichables)
        for i in 1...90 {
            let daysAgo = Double(i) * 1.8
            let date = now.addingTimeInterval(-daysAgo * 86400)
            items.append(CleanableItem(
                id: "7237\(200000 + i)",
                category: .favorites,
                title: "Recette rapide préférée #\(i)",
                authorUsername: "@chef_gourmet",
                timestamp: date,
                videoUrl: URL(string: "https://www.tiktok.com/@chef_gourmet/video/7237\(200000 + i)"),
                thumbnailUrl: URL(string: "https://picsum.photos/seed/\(i + 700)/200/300"),
                likeCount: Int.random(in: 12000...350000)
            ))
        }
        
        return items
    }
}
