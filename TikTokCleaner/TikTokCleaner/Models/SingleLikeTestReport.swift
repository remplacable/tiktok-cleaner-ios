import Foundation

/// Rapport d'exécution détaillé du test de bout en bout sur un like unique.
public struct SingleLikeTestReport: Identifiable, Codable {
    public let id: UUID
    public let videoUrl: String
    public let awemeId: String
    public let endpointUsed: String
    public let httpStatusCode: Int
    public let tiktokStatusCode: Int
    public let tiktokStatusMsg: String
    public let userDiggedBefore: Int? // Doit valoir 1
    public let userDiggedAfter: Int?  // Doit valoir 0
    public let durationSeconds: Double
    public let isSuccess: Bool
    public let securityChallengeEncountered: Bool
    public let errorMessage: String?
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        videoUrl: String,
        awemeId: String,
        endpointUsed: String,
        httpStatusCode: Int,
        tiktokStatusCode: Int,
        tiktokStatusMsg: String,
        userDiggedBefore: Int?,
        userDiggedAfter: Int?,
        durationSeconds: Double,
        isSuccess: Bool,
        securityChallengeEncountered: Bool = false,
        errorMessage: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.videoUrl = videoUrl
        self.awemeId = awemeId
        self.endpointUsed = endpointUsed
        self.httpStatusCode = httpStatusCode
        self.tiktokStatusCode = tiktokStatusCode
        self.tiktokStatusMsg = tiktokStatusMsg
        self.userDiggedBefore = userDiggedBefore
        self.userDiggedAfter = userDiggedAfter
        self.durationSeconds = durationSeconds
        self.isSuccess = isSuccess
        self.securityChallengeEncountered = securityChallengeEncountered
        self.errorMessage = errorMessage
        self.timestamp = timestamp
    }
    
    public var formattedDuration: String {
        return String(format: "%.0f ms", durationSeconds * 1000)
    }
}
