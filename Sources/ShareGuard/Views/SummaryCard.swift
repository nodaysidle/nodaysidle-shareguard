import SwiftUI

struct SummaryCard: View {
    let summary: ScanSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scan Summary")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(statusText)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundStyle(statusColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            HStack(spacing: 16) {
                StatBox(label: "Scanned", value: summary.scannedFiles, color: AppColors.textPrimary)
                StatBox(label: "Skipped", value: summary.skippedFiles, color: AppColors.textSecondary)
                StatBox(label: "Findings", value: summary.totalFindings, color: AppColors.volt)
            }

            HStack(spacing: 12) {
                SeverityPill(count: summary.critical, label: "Critical", color: AppColors.danger)
                SeverityPill(count: summary.high, label: "High", color: AppColors.warning)
                SeverityPill(count: summary.medium, label: "Medium", color: AppColors.volt)
                SeverityPill(count: summary.low, label: "Low", color: AppColors.info)
                SeverityPill(count: summary.info, label: "Info", color: AppColors.textSecondary)
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusText: String {
        if summary.totalFindings == 0 { return "Clean" }
        if summary.critical > 0 { return "Blocked" }
        if summary.high > 0 { return "Risky" }
        return "Review"
    }

    private var statusColor: Color {
        if summary.totalFindings == 0 { return AppColors.success }
        if summary.critical > 0 { return AppColors.danger }
        if summary.high > 0 { return AppColors.warning }
        return AppColors.volt
    }
}

struct StatBox: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SeverityPill: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text("\(count)")
                .font(.caption.bold())
            Text(label)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundStyle(color)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
