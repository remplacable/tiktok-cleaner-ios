import Foundation

/// Modèle représentant un élément individuel du compte TikTok à nettoyer.
public struct CleanableItem: Identifiable, Hashable, Codable {
    public let id: String
    public let category: CleanupCategory
    public let title: String
    public let authorUsername: String?
    public let timestamp: Date
    public let videoUrl: URL?
    public let thumbnailUrl: URL?
    public let viewCount: Int?
    public let likeCount: Int?
    public let durationSeconds: Double?
    public var isSelected: Bool
    public var rawMetadata: [String: String]?
    
    public init(
        id: String,
        category: CleanupCategory,
        title: String,
        authorUsername: String? = nil,
        timestamp: Date,
        videoUrl: URL? = nil,
        thumbnailUrl: URL? = nil,
        viewCount: Int? = nil,
        likeCount: Int? = nil,
        durationSeconds: Double? = nil,
        isSelected: Bool = false,
        rawMetadata: [String: String]? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.authorUsername = authorUsername
        self.timestamp = timestamp
        self.videoUrl = videoUrl
        self.thumbnailUrl = thumbnailUrl
        self.viewCount = viewCount
        self.likeCount = likeCount
        self.durationSeconds = durationSeconds
        self.isSelected = isSelected
        self.rawMetadata = rawMetadata
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: timestamp)
    }
    
    public var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
