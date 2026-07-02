import XCTest
@testable import ShareGuard

/// Deterministic integration smoke: DetectionEngine scans a temp directory
/// containing files with fake placeholder secrets, then asserts expected findings
/// and verifies that no full fake secret appears in any excerpt.
final class DetectionEngineTests: XCTestCase {

    func testEngineScanDetectsSecretsAndRedactsExcerpts() async throws {
        // ── Setup temp directory ──────────────────────────────────────
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ShareGuardEngineTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        // Fake secrets — strictly placeholders, never real credentials
        let fakeAPIKey = "sk-" + "shareguardfakeapitoken1234567890ABCD"
        let fakeEnvValue = "fake-secret-value-12345"
        let fakeEmail = "testuser@example.com"
        let fakeURLToken = "https://example.com/api?token=abcdef1234567890"

        // File 1: API token in plain text
        let apiFile = root.appendingPathComponent("secrets.txt")
        try "api_key = \(fakeAPIKey)".write(to: apiFile, atomically: true, encoding: .utf8)

        // File 2: .env with a secret value
        let envFile = root.appendingPathComponent(".env")
        try "STRIPE_SECRET_KEY=\(fakeEnvValue)".write(to: envFile, atomically: true, encoding: .utf8)

        // File 3: Private key PEM header (use .txt so it is scannable)
        let pemFile = root.appendingPathComponent("key.txt")
        try """
        -----BEGIN PRIVATE KEY-----
        """.write(to: pemFile, atomically: true, encoding: .utf8)

        // File 4: Email in a contacts file
        let contactFile = root.appendingPathComponent("contacts.txt")
        try "Contact: \(fakeEmail)".write(to: contactFile, atomically: true, encoding: .utf8)

        // File 5: URL with query token
        let urlFile = root.appendingPathComponent("urls.txt")
        try fakeURLToken.write(to: urlFile, atomically: true, encoding: .utf8)

        // ── Scan ──────────────────────────────────────────────────────
        let result = await DetectionEngine.shared.scan(urls: [root])

        // ── Summary assertions ────────────────────────────────────────
        // .env also triggers SuspiciousFilenameDetector (extra .high finding)
        XCTAssertGreaterThanOrEqual(result.summary.totalFindings, 6,
            "Should detect at least 6 findings (5 seeded + suspicious .env filename)")
        XCTAssertGreaterThanOrEqual(result.summary.critical, 2,
            "API token + private key = at least 2 critical")
        XCTAssertGreaterThanOrEqual(result.summary.high, 3,
            "Env secret + suspicious .env filename + URL token = at least 3 high")
        XCTAssertGreaterThanOrEqual(result.summary.low, 1,
            "Email = at least 1 low")
        XCTAssertEqual(result.summary.skippedFiles, 0)

        // ── Detector-type coverage ────────────────────────────────────
        let foundDetectors = Set(result.findings.map(\.detector))
        for expected: DetectorType in [.apiToken, .envSecret, .privateKey, .email, .urlToken] {
            XCTAssertTrue(foundDetectors.contains(expected),
                "Should include detector \(expected.rawValue)")
        }

        // ── Redaction proof: no full fake secret in any excerpt ───────
        for finding in result.findings {
            let excerpt = finding.excerpt
            XCTAssertFalse(excerpt.contains(fakeAPIKey),
                "Excerpt must not leak full API key — got: \(excerpt)")
            XCTAssertFalse(excerpt.contains(fakeEnvValue),
                "Excerpt must not leak full env value — got: \(excerpt)")
            XCTAssertFalse(excerpt.contains(fakeEmail),
                "Excerpt must not leak full email — got: \(excerpt)")
            XCTAssertFalse(excerpt.contains(fakeURLToken),
                "Excerpt must not leak full URL token — got: \(excerpt)")
        }

        // ── No read errors ────────────────────────────────────────────
        XCTAssertTrue(result.errors.isEmpty,
            "Should have zero read errors, got: \(result.errors)")
    }
}
