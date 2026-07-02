import XCTest
@testable import ShareGuard

final class RedactionTests: XCTestCase {
    func testRedactTokenShowsHeadAndTail() {
        let token = "sk-" + "abc1234567890abcdef12345678903456"
        let out = Redaction.redactToken(token, visible: 4)
        XCTAssertTrue(out.hasPrefix("sk-a"), "Should keep prefix")
        XCTAssertTrue(out.hasSuffix("3456"), "Should keep suffix")
        XCTAssertTrue(out.contains("\u{2022}"), "Should contain ellipsis")
        XCTAssertFalse(out.contains(token), "Should not reveal full token")
    }

    func testRedactShortToken() {
        let short = "abc"
        let out = Redaction.redactToken(short)
        XCTAssertEqual(out, "a\u{2022}\u{2022}\u{2022}")
    }

    func testRedactEnvValue() {
        let value = "supersecretvalue"
        let out = Redaction.redactEnvValue(value)
        XCTAssertEqual(out, "su\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}")
    }

    func testExcerptRedactsMatch() {
        let token = "sk-" + "abcdef1234567890abcdef12345678wxyz"
        let text = "prefix \(token) suffix"
        let range = text.range(of: token)!
        let out = Redaction.excerpt(text, range: range, window: 10)
        XCTAssertTrue(out.contains("prefix"))
        XCTAssertTrue(out.contains("suffix"))
        XCTAssertFalse(out.contains(token))
    }

    func testLineNumber() {
        let text = "line one\nline two\nline three"
        let range = text.range(of: "line three")!
        XCTAssertEqual(text.lineNumber(at: range.lowerBound), 3)
    }
}
