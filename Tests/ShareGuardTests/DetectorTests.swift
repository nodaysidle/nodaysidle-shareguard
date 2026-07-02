import XCTest
@testable import ShareGuard

final class DetectorTests: XCTestCase {
    func testAPITokenDetection() {
        let fakeToken = "sk-" + "shareguardfakeapitoken1234567890ABCD"
        let content = "api_key = \(fakeToken)"
        let detector = APITokenDetector()
        let findings = detector.scan(filePath: "/tmp/test.txt", content: content)
        XCTAssertFalse(findings.isEmpty)
        XCTAssertEqual(findings.first?.severity, .critical)
        XCTAssertEqual(findings.first?.detector, .apiToken)
    }

    func testEnvSecretDetection() {
        let content = """
        DATABASE_URL=postgres://localhost
        STRIPE_SECRET_KEY=shareguard-fake-env-secret-12345
        DEBUG=true
        """
        let detector = EnvSecretDetector()
        let findings = detector.scan(filePath: "/tmp/.env", content: content)
        XCTAssertEqual(findings.count, 1)
        XCTAssertEqual(findings.first?.detector, .envSecret)
        XCTAssertEqual(findings.first?.severity, .high)
        XCTAssertFalse(findings.first?.excerpt.contains("shareguard-fake-env-secret-12345") ?? true)
    }

    func testPrivateKeyDetection() {
        let content = "-----BEGIN PRIVATE KEY-----"
        let detector = PrivateKeyDetector()
        let findings = detector.scan(filePath: "/tmp/key", content: content)
        XCTAssertEqual(findings.count, 1)
        XCTAssertEqual(findings.first?.severity, .critical)
    }

    func testEmailDetection() {
        let content = "Contact: alice@example.com please"
        let detector = EmailDetector()
        let findings = detector.scan(filePath: "/tmp/emails.txt", content: content)
        XCTAssertEqual(findings.count, 1)
        XCTAssertEqual(findings.first?.severity, .low)
    }

    func testURLTokenDetection() {
        let content = "https://example.com/api?token=abcdef1234567890"
        let detector = URLTokenDetector()
        let findings = detector.scan(filePath: "/tmp/urls.txt", content: content)
        XCTAssertEqual(findings.count, 1)
        XCTAssertEqual(findings.first?.severity, .high)
    }

    func testLocalPathDetection() {
        let content = "path = /Users/alice/Documents/secret.txt"
        let detector = LocalPathDetector()
        let findings = detector.scan(filePath: "/tmp/paths.txt", content: content)
        XCTAssertEqual(findings.count, 1)
        XCTAssertEqual(findings.first?.severity, .medium)
    }

    func testSuspiciousFilename() {
        let detector = SuspiciousFilenameDetector()
        let findings = detector.scan(filePath: "/Users/alice/.ssh/id_rsa", content: "key")
        XCTAssertFalse(findings.isEmpty)
        XCTAssertEqual(findings.first?.severity, .critical)
    }

    func testSeverityScoresAreOrdered() {
        XCTAssertGreaterThan(Severity.critical.score, Severity.high.score)
        XCTAssertGreaterThan(Severity.high.score, Severity.medium.score)
        XCTAssertGreaterThan(Severity.medium.score, Severity.low.score)
        XCTAssertGreaterThan(Severity.low.score, Severity.info.score)
    }
}
