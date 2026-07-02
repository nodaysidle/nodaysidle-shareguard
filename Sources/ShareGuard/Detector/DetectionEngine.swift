import Foundation

/// Central orchestrator that runs all detectors over a list of candidate URLs.
actor DetectionEngine {
    static let shared = DetectionEngine()

    func scan(urls: [URL]) async -> ScanResult {
        var allFindings: [Finding] = []
        var errors: [String] = []
        var scannedFiles = 0
        var skippedFiles = 0

        let expanded = FileEnumerator.collectFiles(from: urls)
        let textFiles = expanded.filter { $0.isScannableTextFile }
        let binaryFiles = expanded.filter { $0.isImageFile || $0.isPDFFile }
        let unsupportedFiles = expanded.filter { !$0.isScannableTextFile && !$0.isImageFile && !$0.isPDFFile }

        for url in textFiles {
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                scannedFiles += 1
                allFindings.append(contentsOf: await runDetectors(on: url, content: content))
            } catch {
                skippedFiles += 1
                errors.append("Could not read \(url.path): \(error.localizedDescription)")
            }
        }

        for url in binaryFiles {
            scannedFiles += 1
            if url.isImageFile {
                allFindings.append(contentsOf: ImageDetector.scan(url: url))
            } else if url.isPDFFile {
                allFindings.append(contentsOf: PDFDetector.scan(url: url))
            }
        }

        skippedFiles += unsupportedFiles.count

        let summary = summarize(findings: allFindings, scannedFiles: scannedFiles, skippedFiles: skippedFiles)
        return ScanResult(summary: summary, findings: allFindings, errors: errors)
    }

    private func runDetectors(on url: URL, content: String) async -> [Finding] {
        var findings: [Finding] = []
        let path = url.path
        let detectors: [Detector] = [
            APITokenDetector(),
            PrivateKeyDetector(),
            EnvSecretDetector(),
            EmailDetector(),
            PhoneDetector(),
            URLTokenDetector(),
            LocalPathDetector(),
            SuspiciousFilenameDetector()
        ]
        for detector in detectors {
            findings.append(contentsOf: detector.scan(filePath: path, content: content))
        }
        return findings
    }

    private func summarize(findings: [Finding], scannedFiles: Int, skippedFiles: Int) -> ScanSummary {
        ScanSummary(
            scannedFiles: scannedFiles,
            skippedFiles: skippedFiles,
            totalFindings: findings.count,
            critical: findings.filter { $0.severity == .critical }.count,
            high: findings.filter { $0.severity == .high }.count,
            medium: findings.filter { $0.severity == .medium }.count,
            low: findings.filter { $0.severity == .low }.count,
            info: findings.filter { $0.severity == .info }.count
        )
    }
}
