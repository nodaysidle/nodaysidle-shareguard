import SwiftUI

struct ContentView: View {
    @State private var viewModel = ScanViewModel()

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 20) {
                        DropZoneView(viewModel: $viewModel)
                        SummaryCard(summary: viewModel.result.summary)
                        FindingsList(findings: viewModel.result.findings)
                        if !viewModel.result.errors.isEmpty {
                            ErrorsSection(errors: viewModel.result.errors)
                        }
                    }
                    .padding(24)
                }
            }
        }
        .foregroundStyle(AppColors.textPrimary)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("ShareGuard")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text("NODAYSIDLE pre-share privacy scanner")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Button(action: { Task { await viewModel.scan() } }) {
                Label("Scan", systemImage: "magnifyingglass")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .buttonStyle(VoltButtonStyle())
            .disabled(viewModel.state == .scanning || viewModel.paths.isEmpty)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(AppColors.surface)
        .overlay(alignment: .bottom) {
            Divider().background(AppColors.surfaceBorder)
        }
    }
}

struct VoltButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(AppColors.background)
            .background(AppColors.volt)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

#Preview {
    ContentView()
}
