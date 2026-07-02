import SwiftUI
import UniformTypeIdentifiers

@Observable
@MainActor
final class ScanViewModel {
    enum State: Equatable {
        case idle
        case scanning
        case complete
    }

    var state: State = .idle
    var paths: [String] = []
    var result: ScanResult = ScanResult(summary: .zero, findings: [], errors: [])

    func addPaths(_ newPaths: [String]) {
        paths = Array(Set(paths + newPaths))
        result = ScanResult(summary: .zero, findings: [], errors: [])
        state = .idle
    }

    func scan() async {
        guard !paths.isEmpty else { return }
        state = .scanning
        let urls = paths.map { URL(fileURLWithPath: $0) }
        let newResult = await DetectionEngine.shared.scan(urls: urls)
        result = newResult
        state = .complete
    }
}
