import SwiftUI

struct SharedGroupRow: View {
    @ObservedObject var store: VibeBoardStore
    @Binding var group: SharedGroup
    var projectId: UUID

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "square.on.square")
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 24)

                TextField(S.detail.sharedGroupName, text: $group.name)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)

                Spacer()

                Button(role: .destructive) {
                    store.removeSharedGroup(group.id, projectId: projectId)
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }

            HStack(spacing: 12) {
                Label(S.detail.sharedGroupPlatforms, systemImage: "desktopcomputer")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)

                FlowLayout(spacing: 6) {
                    ForEach(store.platforms) { platform in
                        PlatformToggleTag(
                            platform: platform,
                            isSelected: group.platformIds.contains(platform.id),
                            onToggle: { togglePlatform(platform.id) }
                        )
                    }
                }
            }

            HStack(spacing: 12) {
                Label(S.detail.sharedGroupRepo, systemImage: "folder")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
                TextField(S.detail.repoName, text: $group.repoName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
            }

            HStack(spacing: 12) {
                Label(S.detail.progress, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
                Slider(value: $group.progress, in: 0...1)
                    .frame(maxWidth: 200)
                Text("\(Int(group.progress * 100))%")
                    .font(.caption.monospacedDigit())
                    .frame(width: 40)
            }

            if !store.languages.isEmpty {
                HStack(alignment: .top, spacing: 12) {
                    Label(S.detail.languages, systemImage: "chevron.left.forwardslash.chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .trailing)
                        .padding(.top, 2)

                    FlowLayout(spacing: 6) {
                        ForEach(store.languages) { language in
                            LanguageToggleTag(
                                language: language,
                                isSelected: group.languages.contains(language),
                                onToggle: { store.toggleLanguageInSharedGroup(language, groupId: group.id, projectId: projectId) }
                            )
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.blue.opacity(0.3), lineWidth: 0.5))
    }

    private func togglePlatform(_ platformId: String) {
        if let index = group.platformIds.firstIndex(of: platformId) {
            group.platformIds.remove(at: index)
        } else {
            group.platformIds.append(platformId)
        }
    }
}

struct PlatformToggleTag: View {
    let platform: Platform
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Image(systemName: platform.icon)
                    .font(.caption2)
                Text(platform.displayName)
                    .font(.subheadline)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .primary : .secondary)
    }
}
