import SwiftUI

struct KeywordTag: View {
    let keyword: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(keyword)
                .font(.subheadline)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(.tint.opacity(0.15))
        .clipShape(Capsule())
    }
}
