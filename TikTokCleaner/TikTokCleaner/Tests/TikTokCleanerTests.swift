import XCTest
@testable import TikTokCleaner

final class TikTokCleanerTests: XCTestCase {
    
    func testGDPRArchiveParsing() throws {
        let sampleJson = """
        {
          "Activity": {
            "Like List": {
              "ItemFavoriteList": [
                {"date": "2026-08-12 14:22:10", "link": "https://www.tiktok.com/@creator/video/7234567890123456789"}
              ]
            },
            "Favorite Videos": {
              "FavoriteVideoList": [
                {"date": "2026-07-04 10:15:00", "link": "https://www.tiktok.com/@creator/video/7234567890123456790"}
              ]
            },
            "Share History": {
              "ShareHistoryList": [
                {"date": "2026-06-20 18:30:00", "link": "https://www.tiktok.com/@creator/video/7234567890123456791"}
              ]
            }
          },
          "Video": {
            "Videos": {
              "VideoList": [
                {"date": "2026-05-10 20:00:00", "video_link": "https://www.tiktok.com/@me/video/7234567890123456792", "likes": "15"}
              ]
            }
          }
        }
        """
        guard let data = sampleJson.data(using: .utf8) else {
            XCTFail("Données invalides")
            return
        }
        
        let items = try GDPRArchiveScanner.shared.parseArchive(jsonData: data)
        XCTAssertEqual(items.count, 4)
        
        let likes = items.filter { $0.category == .likes }
        XCTAssertEqual(likes.count, 1)
        XCTAssertEqual(likes.first?.id, "7234567890123456789")
        
        let favs = items.filter { $0.category == .favorites }
        XCTAssertEqual(favs.count, 1)
        
        let reposts = items.filter { $0.category == .reposts }
        XCTAssertEqual(reposts.count, 1)
        
        let posts = items.filter { $0.category == .posts }
        XCTAssertEqual(posts.count, 1)
        XCTAssertEqual(posts.first?.likeCount, 15)
    }
    
    func testExtractAwemeId() {
        let url1 = "https://www.tiktok.com/@creator/video/7234567890123456789"
        let id1 = GDPRArchiveScanner.shared.extractAwemeId(from: url1)
        XCTAssertEqual(id1, "7234567890123456789")
        
        let url2 = "https://vm.tiktok.com/ZM8923456789/"
        let id2 = GDPRArchiveScanner.shared.extractAwemeId(from: url2)
        XCTAssertTrue(id2.contains("8923456789"))
    }
    
    func testCleanupErrorStructure() {
        let rateLimitErr = CleanupError.rateLimited(retryAfterSeconds: 45)
        XCTAssertTrue(rateLimitErr.isRetryable)
        XCTAssertEqual(rateLimitErr.title, "Limite temporaire atteinte")
        XCTAssertTrue(rateLimitErr.cause.contains("anti-spam"))
        XCTAssertTrue(rateLimitErr.action.contains("45 secondes"))
        
        let sessionErr = CleanupError.sessionExpired
        XCTAssertFalse(sessionErr.isRetryable)
        XCTAssertEqual(sessionErr.title, "Session TikTok expirée")
        XCTAssertTrue(sessionErr.action.contains("rafraîchir"))
    }
    
    func testRateLimitAdaptiveDelay() {
        let settings = RateLimitSettings(
            requestIntervalSeconds: 3.0,
            jitterRangeSeconds: 1.0,
            burstSizeBeforeRest: 20,
            restDurationSeconds: 10.0,
            maxRetriesPerItem: 3
        )
        
        for _ in 1...100 {
            let delay = settings.nextAdaptiveDelay
            XCTAssertGreaterThanOrEqual(delay, 1.0)
            XCTAssertLessThanOrEqual(delay, 4.0)
        }
    }
}
