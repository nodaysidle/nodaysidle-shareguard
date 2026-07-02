import SwiftUI

struct ErrorsSection: View {
    let errors: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Errors")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.danger)

            ForEach(errors, id: \.self) { error in
                Text(error)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
