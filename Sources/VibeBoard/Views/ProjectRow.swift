import SwiftUI

struct ProjectRow: View {
    let project: VibeProject
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                HStack(spacing: 4) {
                    let supported = project.platformStatuses.filter(\.isSupported).count
                    let total = project.platformStatuses.count
                    Text("\(supported)/\(total) \(S.detail.platformCount)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    let allLangs = Array(Set(project.platformStatuses.flatMap(\.languages).map(\.displayName))).sorted()
                    if !allLangs.isEmpty {
                        ForEach(allLangs, id: \.self) { name in
                            Text(name)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.tint.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
