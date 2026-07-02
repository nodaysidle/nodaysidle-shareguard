import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @Binding var viewModel: ScanViewModel
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.volt)

            Text("Drag files or folders here")
                .font(.system(size: 16, weight: .semibold))
            Text(supportedTypes)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            if !viewModel.paths.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.paths, id: \.self) { path in
                        HStack(spacing: 8) {
                            Image(systemName: iconFor(path: path))
                                .foregroundStyle(AppColors.volt)
                            Text(path)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Button {
                                viewModel.paths.removeAll { $0 == path }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(12)
                .background(AppColors.background)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
                .stroke(isTargeted ? AppColors.volt : AppColors.surfaceBorder, lineWidth: isTargeted ? 2 : 1)
        )
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            Task {
                var newPaths: [String] = []
                for provider in providers {
                    if let data = try? await provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        newPaths.append(url.path)
                    }
                }
                await MainActor.run {
                    viewModel.addPaths(newPaths)
                }
            }
            return true
        }
    }

    private var supportedTypes: String {
        "md, txt, json, env, plist, yaml, yml, csv, log, pdf, png, jpg, jpeg"
    }

    private func iconFor(path: String) -> String {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue {
            return "folder.fill"
        }
        return "doc.text.fill"
    }
}
