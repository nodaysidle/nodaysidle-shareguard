import SwiftUI

struct FindingsList: View {
    let findings: [Finding]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Findings")
                .font(.system(size: 16, weight: .semibold))

            if findings.isEmpty {
                Text("No findings yet. Drag files and tap Scan.")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(findings) { finding in
                        FindingRow(finding: finding)
                    }
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FindingRow: View {
    let finding: Finding

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                severityBadge

                VStack(alignment: .leading, spacing: 4) {
                    Text(finding.detector.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                    Text(finding.filePath)
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                    if let line = finding.line {
                        Text("Line \(line)")
                            .font(.caption2)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer()
            }

            Text(finding.excerpt)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(AppColors.textPrimary)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.background)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(finding.remediation)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(12)
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(SeverityColor.color(for: finding.severity).opacity(0.4), lineWidth: 1)
        )
    }

    private var severityBadge: some View {
        Text(finding.severity.rawValue)
            .font(.caption2.bold())
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(SeverityColor.color(for: finding.severity).opacity(0.2))
            .foregroundStyle(SeverityColor.color(for: finding.severity))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
