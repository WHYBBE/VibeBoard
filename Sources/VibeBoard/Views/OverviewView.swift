import SwiftUI

struct OverviewView: View {
    @ObservedObject var store: VibeBoardStore
    var onProjectTap: (UUID) -> Void

    var body: some View {
        ScrollView {
            if store.projects.isEmpty {
                ContentUnavailableView(
                    S.sidebar.noProject,
                    systemImage: "folder.badge.plus",
                    description: Text(S.sidebar.noProjectHint)
                )
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(store.projects) { project in
                        overviewCard(project)
                            .onTapGesture { onProjectTap(project.id) }
                    }
                }
                .padding(28)
            }
        }
        .background(.background)
    }

    private func overviewCard(_ project: VibeProject) -> some View {
        let boundSubs = store.subProjects.filter { sub in project.subProjectIds.contains(sub.id) }

        return VStack(alignment: .leading, spacing: 12) {
            Text(project.name)
                .font(.title2.bold())
                .lineLimit(1)

            if !project.keywords.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(project.keywords, id: \.self) { kw in
                        Text(kw)
                            .font(.callout.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.tint.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }

            if !boundSubs.isEmpty {
                Divider()

                VStack(spacing: 10) {
                    ForEach(boundSubs) { sub in
                        subProjectRow(sub)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.gray.opacity(0.12), lineWidth: 0.5))
    }

    private func subProjectRow(_ sub: SubProject) -> some View {
        HStack(spacing: 10) {
            HStack(spacing: 5) {
                Image(systemName: sub.isShared ? "link.circle.fill" : "cube.box")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(sub.isShared ? .blue : .orange)

                Text(sub.name.isEmpty ? S.detail.subProjectName : sub.name)
                    .font(.callout.weight(.medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(sub.isShared ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
            .clipShape(Capsule())

            HStack(spacing: 1) {
                ForEach(sub.platformIds, id: \.self) { pid in
                    let p = store.platforms.first { $0.id == pid }
                    Image(systemName: p?.icon ?? "questionmark.square")
                        .font(.caption)
                }
            }

            FlowLayout(spacing: 5) {
                ForEach(sub.languages.filter { store.validLanguageIds.contains($0.id) }) { lang in
                    langChip(lang.displayName)
                }
                ForEach(sub.llmTags.filter { store.validLLMTagIds.contains($0.id) }) { tag in
                    llmChip(tag.displayName)
                }
                if sub.progress > 0 {
                    progressChip(sub.progress)
                }
            }

            Spacer(minLength: 0)
        }
    }

    private func langChip(_ name: String) -> some View {
        Text(name)
            .font(.callout.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.tint.opacity(0.12))
            .clipShape(Capsule())
    }

    private func llmChip(_ name: String) -> some View {
        Text(name)
            .font(.callout.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.purple.opacity(0.12))
            .clipShape(Capsule())
    }

    private func progressChip(_ progress: Double) -> some View {
        Text("\(Int(progress * 100))%")
            .font(.callout.weight(.semibold).monospacedDigit())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(progress >= 1 ? .green : .secondary)
            .background(progress >= 1 ? Color.green.opacity(0.12) : Color.gray.opacity(0.08))
            .clipShape(Capsule())
    }
}
