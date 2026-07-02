import Foundation

enum Severity: String, CaseIterable, Codable, Sendable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case info = "Info"

    var score: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        case .info: return 0
        }
    }
}

enum DetectorType: String, CaseIterable, Codable, Sendable {
    case apiToken = "API / Token"
    case privateKey = "Private Key"
    case envSecret = "Env Secret"
    case email = "Email"
    case phone = "Phone"
    case urlToken = "URL Token"
    case localPath = "Local Path"
    case suspiciousFilename = "Suspicious Filename"
    case imageMetadata = "Image Metadata"
    case pdfContent = "PDF Content"
    case unknown = "Unknown"
}

struct Finding: Identifiable, Sendable {
    let id = UUID()
    let severity: Severity
    let detector: DetectorType
    let filePath: String
    let line: Int?
    let excerpt: String
    let remediation: String
}

struct ScanSummary: Sendable {
    let scannedFiles: Int
    let skippedFiles: Int
    let totalFindings: Int
    let critical: Int
    let high: Int
    let medium: Int
    let low: Int
    let info: Int

    static let zero = ScanSummary(
        scannedFiles: 0,
        skippedFiles: 0,
        totalFindings: 0,
        critical: 0,
        high: 0,
        medium: 0,
        low: 0,
        info: 0
    )
}

struct ScanResult: Sendable {
    let summary: ScanSummary
    let findings: [Finding]
    let errors: [String]
}
