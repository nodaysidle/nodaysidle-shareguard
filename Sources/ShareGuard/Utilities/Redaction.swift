import Foundation

enum Redaction {
    /// Keeps the first and last `visible` characters of a token, replacing the middle with `•`.
    /// If the value is shorter than `minLength`, keeps only the first character + `•`.
    static func redactToken(_ value: String, visible: Int = 4, minLength: Int = 10) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "[empty]" }
        if trimmed.count < minLength {
            let keep = min(1, trimmed.count)
            return String(trimmed.prefix(keep)) + "•••"
        }
        let prefix = String(trimmed.prefix(visible))
        let suffix = String(trimmed.suffix(visible))
        return "\(prefix)•••••••••\(suffix)"
    }

    /// Redacts an environment value, showing only first 2 chars if present.
    static func redactEnvValue(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "[empty value]" }
        if trimmed.count <= 4 {
            return String(repeating: "•", count: trimmed.count)
        }
        let prefix = String(trimmed.prefix(2))
        return "\(prefix)•••••••••"
    }

    /// Produces a short excerpt around a match, redacting the matched value.
    static func excerpt(_ text: String, range: Range<String.Index>, window: Int = 24) -> String {
        let start = text.index(text.startIndex, offsetBy: max(0, text.distance(from: text.startIndex, to: range.lowerBound) - window), limitedBy: range.lowerBound) ?? text.startIndex
        let end = text.index(range.upperBound, offsetBy: window, limitedBy: text.endIndex) ?? text.endIndex
        let before = String(text[start..<range.lowerBound])
        let after = String(text[range.upperBound..<end])
        let middle = redactToken(String(text[range]))
        let raw = before + middle + after
        return raw
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .trimmingCharacters(in: .whitespaces)
    }

    static func redactFilename(_ name: String) -> String {
        "[suspicious: \(name)]"
    }
}
