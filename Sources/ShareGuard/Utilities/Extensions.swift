import Foundation

extension URL {
    var isImageFile: Bool {
        let ext = pathExtension.lowercased()
        return ["png", "jpg", "jpeg"].contains(ext)
    }

    var isPDFFile: Bool {
        pathExtension.lowercased() == "pdf"
    }

    var isScannableTextFile: Bool {
        let supported = [
            "md", "txt", "json", "env", "plist", "yaml", "yml",
            "csv", "log"
        ]
        let ext = pathExtension.lowercased()
        let base = deletingPathExtension().lastPathComponent
        return supported.contains(ext) || base.hasPrefix(".env")
    }
}

extension String {
    func lineNumber(at index: String.Index) -> Int {
        let prefix = self[..<index]
        return prefix.components(separatedBy: "\n").count
    }
}
