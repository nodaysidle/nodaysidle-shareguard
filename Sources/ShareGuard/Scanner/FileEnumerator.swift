import Foundation

enum FileEnumerator {
    static let ignoredDirectoryNames: Set<String> = [
        ".git", ".build", "node_modules", "target", "DerivedData", ".swiftpm",
        ".idea", ".vscode", "__pycache__"
    ]

    static func collectFiles(from urls: [URL]) -> [URL] {
        var collected: [URL] = []
        let fileManager = FileManager.default
        for url in urls {
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                collected.append(contentsOf: enumerateDirectory(url))
            } else {
                collected.append(url)
            }
        }
        return Array(Set(collected)).sorted { $0.path < $1.path }
    }

    static func enumerateDirectory(_ url: URL) -> [URL] {
        var result: [URL] = []
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsPackageDescendants]
        ) else { return result }

        for case let itemURL as URL in enumerator {
            let name = itemURL.lastPathComponent
            if ignoredDirectoryNames.contains(name) {
                enumerator.skipDescendants()
                continue
            }
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDir), !isDir.boolValue {
                result.append(itemURL)
            }
        }
        return result
    }

    static func isIgnoredDirectory(_ url: URL) -> Bool {
        ignoredDirectoryNames.contains(url.lastPathComponent)
    }
}
