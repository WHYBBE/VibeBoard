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
                VStack(spacing: 12) {
                    ForEach(store.projects) { project in
                        overviewCard(project)
                            .onTapGesture { onProjectTap(project.id) }
                    }
                }
                .padding(20)
            }
        }
    }

    private func overviewCard(_ project: VibeProject) -> some View {
        HStack(alignment: .top, spacing: 14) {
            overviewLeft(project)
            overviewRight(project)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray.opacity(0.15), lineWidth: 0.5))
    }

    private func overviewLeft(_ project: VibeProject) -> some View {
        let supported = project.platformStatuses.filter(\.isSupported).count
        let total = project.platformStatuses.count

        return VStack(alignment: .leading, spacing: 4) {
            Text(project.name)
                .font(.headline)
                .lineLimit(1)

            Text(project.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)

            if !project.keywords.isEmpty {
                FlowLayout(spacing: 4) {
                    ForEach(project.keywords, id: \.self) { kw in
                        Text(kw)
                            .font(.system(size: 9))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(.tint.opacity(0.08))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)

            Text("\(supported)/\(total)")
                .font(.caption.monospacedDigit().bold())
                .foregroundStyle(supported == total && total > 0 ? .green : .secondary)
        }
        .frame(width: 140, alignment: .leading)
    }

    private func overviewRight(_ project: VibeProject) -> some View {
        let sharedPlatformIds = Set(project.sharedGroups.flatMap(\.platformIds))

        return VStack(spacing: 4) {
            ForEach(project.sharedGroups) { group in
                sharedGroupRow(group)
            }

            ForEach(project.platformStatuses.filter { !sharedPlatformIds.contains($0.platformId) }) { status in
                platformRow(status)
            }
        }
    }

    private func sharedGroupRow(_ group: SharedGroup) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "square.on.square")
                .font(.caption2)
                .foregroundStyle(.blue)

            HStack(spacing: 2) {
                ForEach(Array(group.platformIds.enumerated()), id: \.offset) { i, pid in
                    let p = store.platforms.first { $0.id == pid }
                    if i > 0 { Text("+").font(.system(size: 8)).foregroundStyle(.tertiary) }
                    Image(systemName: p?.icon ?? "questionmark.square").font(.caption2)
                }
            }

            if !group.name.isEmpty {
                Text(group.name).font(.caption2).foregroundStyle(.secondary)
            }

            Spacer()

            langTags(group.languages)

            if group.progress > 0 { pctLabel(group.progress) }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    private func platformRow(_ status: PlatformStatus) -> some View {
        let platform = store.platforms.first { $0.id == status.platformId }

        return HStack(spacing: 6) {
            Image(systemName: platform?.icon ?? "questionmark.square")
                .font(.caption2)
                .foregroundStyle(status.isSupported ? .green : Color.gray.opacity(0.4))

            Text(platform?.displayName ?? status.platformId)
                .font(.caption)
                .frame(width: 64, alignment: .leading)
                .foregroundStyle(status.isSupported ? .primary : .secondary)

            Spacer()

            langTags(status.languages)

            if status.isSupported, status.progress > 0 {
                pctLabel(status.progress)
            }
        }
        .frame(height: 20)
        .opacity(status.isSupported ? 1 : 0.4)
    }

    private func langTags(_ languages: [Language]) -> some View {
        HStack(spacing: 3) {
            ForEach(languages) { lang in
                Text(lang.displayName)
                    .font(.system(size: 9))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(.tint.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }

    private func pctLabel(_ progress: Double) -> some View {
        Text("\(Int(progress * 100))%")
            .font(.system(size: 9).monospacedDigit())
            .foregroundStyle(.secondary)
            .frame(width: 28, alignment: .trailing)
    }
}
