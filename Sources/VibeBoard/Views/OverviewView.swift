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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16)], spacing: 16) {
                    ForEach(store.projects) { project in
                        overviewCard(project)
                            .onTapGesture {
                                onProjectTap(project.id)
                            }
                    }
                }
                .padding(20)
            }
        }
    }

    private func overviewCard(_ project: VibeProject) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom, spacing: 12) {
                Text(project.name)
                    .font(.title3.bold())
                    .lineLimit(1)
                Spacer()
                Text(project.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            let supported = project.platformStatuses.filter(\.isSupported).count
            let total = project.platformStatuses.count
            HStack(spacing: 12) {
                miniBadge(value: supported, label: S.detail.supported, color: .green)
                miniBadge(value: total - supported, label: S.detail.notSupported, color: .orange)
                miniBadge(value: project.sharedGroups.count, label: S.detail.sharedGroups, color: .blue)
            }

            if !project.keywords.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(project.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.tint.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }

            let sharedPlatformIds = Set(project.sharedGroups.flatMap(\.platformIds))

            if !project.sharedGroups.isEmpty {
                ForEach(project.sharedGroups) { group in
                    overviewSharedGroupRow(group)
                }
            }

            let standaloneSupported = project.platformStatuses.filter { $0.isSupported && !sharedPlatformIds.contains($0.platformId) }
            let standaloneUnsupported = project.platformStatuses.filter { !$0.isSupported && !sharedPlatformIds.contains($0.platformId) }

            if !standaloneSupported.isEmpty {
                if !project.sharedGroups.isEmpty {
                    Divider()
                }
                ForEach(standaloneSupported) { status in
                    overviewPlatformRow(status)
                }
            }

            if !standaloneUnsupported.isEmpty {
                if !project.sharedGroups.isEmpty || !standaloneSupported.isEmpty {
                    Divider()
                }
                ForEach(standaloneUnsupported) { status in
                    overviewPlatformRow(status)
                }
                .opacity(0.5)
            }
        }
        .padding(16)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.gray.opacity(0.2), lineWidth: 0.5))
    }

    private func miniBadge(value: Int, label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(value)")
                .font(.caption.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func overviewSharedGroupRow(_ group: SharedGroup) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "square.on.square")
                .font(.callout)
                .foregroundStyle(.blue)
                .frame(width: 18)

            HStack(spacing: 4) {
                ForEach(Array(group.platformIds.enumerated()), id: \.offset) { index, pid in
                    let p = store.platforms.first { $0.id == pid }
                    if index > 0 {
                        Text("+")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: p?.icon ?? "questionmark.square")
                        .font(.caption)
                }
                if !group.name.isEmpty {
                    Text(group.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                ForEach(group.languages) { lang in
                    Text(lang.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(.tint.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            if group.progress > 0 {
                Text("\(Int(group.progress * 100))%")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(6)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func overviewPlatformRow(_ status: PlatformStatus) -> some View {
        let platform = store.platforms.first { $0.id == status.platformId }

        return HStack(spacing: 8) {
            Image(systemName: platform?.icon ?? "questionmark.square")
                .font(.callout)
                .foregroundStyle(status.isSupported ? .green : .secondary)
                .frame(width: 18)

            Text(platform?.displayName ?? status.platformId)
                .font(.callout.weight(.medium))

            Spacer()

            if !status.languages.isEmpty {
                HStack(spacing: 4) {
                    ForEach(status.languages) { lang in
                        Text(lang.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(.tint.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }

            if status.isSupported, status.progress > 0 {
                Text("\(Int(status.progress * 100))%")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
