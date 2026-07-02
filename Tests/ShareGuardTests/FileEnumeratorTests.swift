import XCTest
@testable import ShareGuard

final class FileEnumeratorTests: XCTestCase {
    func testIgnoredDirectories() {
        XCTAssertTrue(FileEnumerator.isIgnoredDirectory(URL(fileURLWithPath: "/tmp/node_modules")))
        XCTAssertTrue(FileEnumerator.isIgnoredDirectory(URL(fileURLWithPath: "/tmp/.git")))
        XCTAssertTrue(FileEnumerator.isIgnoredDirectory(URL(fileURLWithPath: "/tmp/DerivedData")))
        XCTAssertFalse(FileEnumerator.isIgnoredDirectory(URL(fileURLWithPath: "/tmp/src")))
    }

    func testRecursiveEnumerationIgnoresBuildDirs() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ShareGuardEnumTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let src = root.appendingPathComponent("src")
        let nodeModules = root.appendingPathComponent("node_modules")
        try FileManager.default.createDirectory(at: src, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: nodeModules, withIntermediateDirectories: true)

        try "secret".write(to: src.appendingPathComponent("a.txt"), atomically: true, encoding: .utf8)
        try "ignore".write(to: nodeModules.appendingPathComponent("b.txt"), atomically: true, encoding: .utf8)

        let files = FileEnumerator.collectFiles(from: [root])
        XCTAssertEqual(files.count, 1)
        XCTAssertTrue(files.first?.lastPathComponent == "a.txt")
    }

    func testRecursiveEnumerationIncludesSecurityRelevantHiddenFiles() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ShareGuardHiddenTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let ssh = root.appendingPathComponent(".ssh")
        let git = root.appendingPathComponent(".git")
        try FileManager.default.createDirectory(at: ssh, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: git, withIntermediateDirectories: true)
        try "OPENAI_API_KEY=dummy-secret-value".write(to: root.appendingPathComponent(".env"), atomically: true, encoding: .utf8)
        try "private".write(to: ssh.appendingPathComponent("id_rsa"), atomically: true, encoding: .utf8)
        try "ignored".write(to: git.appendingPathComponent("config"), atomically: true, encoding: .utf8)

        let names = Set(FileEnumerator.collectFiles(from: [root]).map(\.lastPathComponent))
        XCTAssertTrue(names.contains(".env"))
        XCTAssertTrue(names.contains("id_rsa"))
        XCTAssertFalse(names.contains("config"))
    }

    func testIndividualFilePassedThrough() throws {
        let file = FileManager.default.temporaryDirectory
            .appendingPathComponent("single-\(UUID().uuidString).txt")
        try "x".write(to: file, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: file) }

        let files = FileEnumerator.collectFiles(from: [file])
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files.first?.path, file.path)
    }
}
