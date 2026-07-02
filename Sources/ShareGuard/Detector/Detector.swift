import Foundation
import CoreGraphics
import ImageIO
protocol Detector {
    func scan(filePath: String, content: String) -> [Finding]
}

struct APITokenDetector: Detector {
    private let patterns: [(NSRegularExpression, Severity)] = [
        (try! NSRegularExpression(pattern: "\\b(sk-[a-zA-Z0-9]{32,})\\b", options: []), .critical),
        (try! NSRegularExpression(pattern: "\\b(gh[pousr]_[A-Za-z0-9_]{36,})\\b", options: []), .critical),
        (try! NSRegularExpression(pattern: "\\b(xox[baprs]-[0-9]{10,}-[0-9]{10,}-[A-Za-z0-9]{24,})\\b", options: []), .critical),
        (try! NSRegularExpression(pattern: "\\b(A[SK]IA[0-9A-Z]{16})\\b", options: []), .high),
        (try! NSRegularExpression(pattern: "\\b([A-Za-z0-9_]{20,}api[_-]?key[A-Za-z0-9_]{10,})\\b", options: .caseInsensitive), .medium),
    ]

    func scan(filePath: String, content: String) -> [Finding] {
        var findings: [Finding] = []
        for (regex, severity) in patterns {
            let matches = regex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
            for match in matches {
                guard let range = Range(match.range(at: 1), in: content) else { continue }
                findings.append(Finding(
                    severity: severity,
                    detector: .apiToken,
                    filePath: filePath,
                    line: content.lineNumber(at: range.lowerBound),
                    excerpt: Redaction.excerpt(content, range: range),
                    remediation: "Rotate the token and store it in a secrets manager or environment variable, never in source."
                ))
            }
        }
        return findings
    }
}

struct PrivateKeyDetector: Detector {
    private let headerPattern = try! NSRegularExpression(pattern: "-----BEGIN ([A-Z ]+ )?(PRIVATE KEY|ENCRYPTED PRIVATE KEY|OPENSSH PRIVATE KEY)-----", options: [])

    func scan(filePath: String, content: String) -> [Finding] {
        var findings: [Finding] = []
        let matches = headerPattern.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        for match in matches {
            guard let range = Range(match.range, in: content) else { continue }
            findings.append(Finding(
                severity: .critical,
                detector: .privateKey,
                filePath: filePath,
                line: content.lineNumber(at: range.lowerBound),
                excerpt: Redaction.excerpt(content, range: range),
                remediation: "Remove private key files from the share; use a key manager or encrypted vault."
            ))
        }
        return findings
    }
}

struct EnvSecretDetector: Detector {
    // Match KEY=VALUE, allowing KEY to be quoted, ignoring comments and empty values.
    private let envPattern = try! NSRegularExpression(
        pattern: "^\\s*([A-Za-z_][A-Za-z0-9_]*?)\\s*=\\s*['\"]?([^\\s'\"][^#'\"\\n]*)['\"]?\\s*$",
        options: [.anchorsMatchLines]
    )

    func scan(filePath: String, content: String) -> [Finding] {
        var findings: [Finding] = []
        let matches = envPattern.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        for match in matches {
            guard let keyRange = Range(match.range(at: 1), in: content),
                  let valueRange = Range(match.range(at: 2), in: content) else { continue }
            let key = String(content[keyRange])
            let value = String(content[valueRange])
            guard shouldFlag(key: key, value: value) else { continue }
            let excerpt = "\(key)=\(Redaction.redactEnvValue(value))"
            findings.append(Finding(
                severity: .high,
                detector: .envSecret,
                filePath: filePath,
                line: content.lineNumber(at: keyRange.lowerBound),
                excerpt: excerpt,
                remediation: "Move secrets out of .env files committed or shared; load them via a secrets manager."
            ))
        }
        return findings
    }

    private func shouldFlag(key: String, value: String) -> Bool {
        let lower = key.lowercased()
        let secretTokens = ["key", "secret", "token", "password", "passwd", "api", "auth", "credential", "private", "access"]
        let denylist = ["localhost", "127.0.0.1", "true", "false", "none", "null", "development", "production", "staging"]
        let hasSecretToken = secretTokens.contains { lower.contains($0) }
        let isDenylisted = denylist.contains(value.lowercased()) || denylist.contains { lower.contains($0) }
        return hasSecretToken && !isDenylisted && value.count >= 6
    }
}

struct EmailDetector: Detector {
    private let emailPattern = try! NSRegularExpression(pattern: "([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,})", options: [])

    func scan(filePath: String, content: String) -> [Finding] {
        var findings: [Finding] = []
        let matches = emailPattern.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        for match in matches {
            guard let range = Range(match.range(at: 1), in: content) else { continue }
            findings.append(Finding(
                severity: .low,
                detector: .email,
                filePath: filePath,
                line: content.lineNumber(at: range.lowerBound),
                excerpt: Redaction.excerpt(content, range: range),
                remediation: "Confirm email addresses are intended for public sharing; consider obfuscating."
            ))
        }
        return findings
    }
}

struct PhoneDetector: Detector {
    // Very loose phone-ish pattern: optional +, country code optional, groups of 7-15 digits with separators.
    private let phonePattern = try! NSRegularExpression(pattern: #"(?<![0-9])(\+?[0-9]{1,3}[\s\-\.]?\(?[0-9]{2,4}\)?[\s\-\.]?[0-9]{3,4}[\s\-\.]?[0-9]{3,4})(?![0-9])"#, options: [])

    func scan(filePath: String, content: String) -> [Finding] {
        var findings: [Finding] = []
        let matches = phonePattern.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        for match in matches {
            guard let range = Range(match.range(at: 1), in: content) else { continue }
            let candidate = String(content[range])
            guard candidate.filter({ $0.isNumber }).count >= 7 else { continue }
            findings.append(Finding(
                severity: .low,
                detector: .phone,
                filePath: filePath,
                line: content.lineNumber(at: range.lowerBound),
                excerpt: Redaction.excerpt(content, range: range),
                remediation: "Review whether phone numbers should be shared publicly."
            ))
        }
        return findings
    }
}

struct URLTokenDetector: Detector {
    private let urlPattern = try! NSRegularExpression(
        pattern: "https?://[^\\s\"]+[?&](token|api[_-]?key|auth|session|signature)=[^\\s\"&]+",
        options: [.caseInsensitive]
    )

    func scan(filePath: String, content: String) -> [Finding] {
        var findings: [Finding] = []
        let matches = urlPattern.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        for match in matches {
            guard let range = Range(match.range, in: content) else { continue }
            findings.append(Finding(
                severity: .high,
                detector: .urlToken,
                filePath: filePath,
                line: content.lineNumber(at: range.lowerBound),
                excerpt: Redaction.excerpt(content, range: range),
                remediation: "Remove credentials from URLs; use headers or environment variables."
            ))
        }
        return findings
    }
}

struct LocalPathDetector: Detector {
    private let pathPattern = try! NSRegularExpression(
        pattern: #"(/Users/[A-Za-z0-9_.\-]+(?:/[A-Za-z0-9_.\-\s]+)+)"#,
        options: []
    )

    func scan(filePath: String, content: String) -> [Finding] {
        var findings: [Finding] = []
        let matches = pathPattern.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        for match in matches {
            guard let range = Range(match.range(at: 1), in: content) else { continue }
            let path = String(content[range])
            guard path.contains("/") else { continue }
            findings.append(Finding(
                severity: .medium,
                detector: .localPath,
                filePath: filePath,
                line: content.lineNumber(at: range.lowerBound),
                excerpt: Redaction.excerpt(content, range: range),
                remediation: "Replace absolute local paths with relative or anonymized references."
            ))
        }
        return findings
    }
}

struct SuspiciousFilenameDetector: Detector {
    private let suspicious: [(String, DetectorType, Severity)] = [
        ("id_rsa", .privateKey, .critical),
        (".pem", .suspiciousFilename, .high),
        (".p12", .suspiciousFilename, .critical),
        (".mobileprovision", .suspiciousFilename, .high),
        (".env", .envSecret, .high)
    ]

    func scan(filePath: String, content: String) -> [Finding] {
        let filename = (filePath as NSString).lastPathComponent
        var findings: [Finding] = []
        for (marker, detector, severity) in suspicious {
            if filename.contains(marker) {
                let remediation: String
                switch detector {
                case .privateKey: remediation = "Do not share private key files."
                case .envSecret: remediation = "Do not share .env files containing secrets."
                default: remediation = "Review this sensitive file before sharing."
                }
                findings.append(Finding(
                    severity: severity,
                    detector: detector,
                    filePath: filePath,
                    line: nil,
                    excerpt: Redaction.redactFilename(filename),
                    remediation: remediation
                ))
                break
            }
        }
        return findings
    }
}

struct ImageDetector {
    static func scan(url: URL) -> [Finding] {
        var findings: [Finding] = []
        if let metadata = readImageMetadata(url: url) {
            let excerpt = metadata
                .replacingOccurrences(of: "\n", with: " ")
                .prefix(140)
            findings.append(Finding(
                severity: .info,
                detector: .imageMetadata,
                filePath: url.path,
                line: nil,
                excerpt: "OCR not enabled in first slice; metadata: \(excerpt)",
                remediation: "For photos, manually review EXIF/GPS metadata and visible text before sharing."
            ))
        } else {
            findings.append(Finding(
                severity: .info,
                detector: .imageMetadata,
                filePath: url.path,
                line: nil,
                excerpt: "OCR not enabled in first slice; no readable metadata.",
                remediation: "For photos, manually review EXIF/GPS metadata and visible text before sharing."
            ))
        }
        return findings
    }

    private static func readImageMetadata(url: URL) -> String? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        guard let metadata = CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil) else { return nil }
        let tags = CGImageMetadataCopyTags(metadata) as? [CGImageMetadataTag]
        let pairs = tags?.compactMap { tag -> String? in
            guard let name = CGImageMetadataTagCopyName(tag) as String?,
                  let value = CGImageMetadataTagCopyValue(tag) else { return nil }
            return "\(name)=\(value)"
        }
        return pairs?.joined(separator: "; ")
    }
}

struct PDFDetector {
    static func scan(url: URL) -> [Finding] {
        // First slice: PDF text extraction is not implemented. We still flag the PDF so the user knows.
        [Finding(
            severity: .info,
            detector: .pdfContent,
            filePath: url.path,
            line: nil,
            excerpt: "PDF text extraction is not implemented in first slice; manual review only before sharing.",
            remediation: "Open the PDF and search for names, addresses, emails, phone numbers, and account numbers."
        )]
    }
}
