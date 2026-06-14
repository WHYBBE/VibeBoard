import SwiftUI

struct ProjectRow: View {
    let project: VibeProject
    let isSelected: Bool
    let subProjectCount: Int

    init(project: VibeProject, isSelected: Bool, subProjectCount: Int = 0) {
        self.project = project
        self.isSelected = isSelected
        self.subProjectCount = subProjectCount
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                HStack(spacing: 4) {
                    Text("\(subProjectCount) \(S.detail.subProjects)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
