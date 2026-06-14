import SwiftUI

struct SubProjectRow: View {
    @ObservedObject var store: VibeBoardStore
    @Binding var subProject: SubProject
    var projectId: UUID?
    var standalone: Bool = false
    @State private var showDeleteConfirm = false

    var body: some View {
        if standalone {
            standaloneLayout
        } else {
            cardLayout
        }
    }

    private var cardLayout: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: subProject.isShared ? "link.circle.fill" : "cube.box")
                    .font(.title3)
                    .foregroundStyle(subProject.isShared ? .blue : .orange)
                    .frame(width: 24)

                TextField(S.detail.subProjectName, text: $subProject.name)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)

                Spacer()

                Toggle(S.detail.implemented, isOn: $subProject.isSupported)
                    .toggleStyle(.switch)

                if let projectId = projectId {
                    Button(S.detail.unbind) {
                        store.unbindSubProject(subProject.id, fromProject: projectId)
                    }
                    .controlSize(.small)
                }

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .alert(S.detail.deleteSubProjectConfirmTitle, isPresented: $showDeleteConfirm) {
                    Button(S.detail.deleteSubProjectConfirmTitle, role: .destructive) {
                        store.deleteSubProject(subProject.id)
                    }
                    Button(S.sidebar.cancel, role: .cancel) {}
                } message: {
                    Text(S.detail.deleteSubProjectConfirmMessage)
                }
            }

            HStack(spacing: 12) {
                Label(S.detail.repoURL, systemImage: "link")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
                TextField(S.detail.repoURL, text: $subProject.repoURL)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
            }

            HStack(spacing: 12) {
                Label(S.detail.progress, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
                Slider(value: $subProject.progress, in: 0...1)
                    .frame(maxWidth: 200)
                Text("\(Int(subProject.progress * 100))%")
                    .font(.caption.monospacedDigit())
                    .frame(width: 40)
            }

            if !store.platforms.isEmpty {
                HStack(alignment: .top, spacing: 12) {
                    Label(S.detail.subProjectPlatforms, systemImage: "desktopcomputer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .trailing)
                        .padding(.top, 2)

                    FlowLayout(spacing: 6) {
                        ForEach(store.platforms) { platform in
                            PlatformToggleTag(
                                platform: platform,
                                isSelected: subProject.platformIds.contains(platform.id),
                                onToggle: { store.togglePlatformInSubProject(platform.id, subProjectId: subProject.id) }
                            )
                        }
                    }
                }
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
                                isSelected: subProject.languages.contains(language),
                                onToggle: { store.toggleLanguageInSubProject(language, subProjectId: subProject.id) }
                            )
                        }
                    }
                }
            }

            if !store.llmTags.isEmpty {
                HStack(alignment: .top, spacing: 12) {
                    Label(S.detail.llmTags, systemImage: "cpu")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .trailing)
                        .padding(.top, 2)

                    FlowLayout(spacing: 6) {
                        ForEach(store.llmTags) { tag in
                            LLMTagToggleTag(
                                tag: tag,
                                isSelected: subProject.llmTags.contains(tag),
                                onToggle: { store.toggleLLMTagInSubProject(tag, subProjectId: subProject.id) }
                            )
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(subProject.isShared ? Color.blue.opacity(0.05) : Color.orange.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(
            subProject.isShared ? Color.blue.opacity(0.3) : Color.orange.opacity(0.3),
            lineWidth: 0.5
        ))
    }

    private var standaloneLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                standaloneHeader
                standaloneFieldsCard
                standalonePlatformsCard
                standaloneLanguagesCard
                standaloneLLMTagsCard
            }
            .padding(24)
        }
    }

    private var standaloneHeader: some View {
        HStack(alignment: .bottom, spacing: 16) {
            Image(systemName: subProject.isShared ? "link.circle.fill" : "cube.box")
                .font(.title)
                .foregroundStyle(subProject.isShared ? .blue : .orange)

            TextField(S.detail.subProjectName, text: $subProject.name)
                .font(.title.bold())
                .textFieldStyle(.roundedBorder)

            Spacer()

            Toggle(S.detail.implemented, isOn: $subProject.isSupported)
                .toggleStyle(.switch)

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
            }
            .alert(S.detail.deleteSubProjectConfirmTitle, isPresented: $showDeleteConfirm) {
                Button(S.detail.deleteSubProjectConfirmTitle, role: .destructive) {
                    store.deleteSubProject(subProject.id)
                }
                Button(S.sidebar.cancel, role: .cancel) {}
            } message: {
                Text(S.detail.deleteSubProjectConfirmMessage)
            }
        }
    }

    private var standaloneFieldsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Label(S.detail.repoURL, systemImage: "link")
                    .font(.headline)
                    .frame(width: 80, alignment: .trailing)
                TextField(S.detail.repoURL, text: $subProject.repoURL)
                    .textFieldStyle(.roundedBorder)
            }

            HStack(spacing: 12) {
                Label(S.detail.progress, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                    .frame(width: 80, alignment: .trailing)
                Slider(value: $subProject.progress, in: 0...1)
                Text("\(Int(subProject.progress * 100))%")
                    .font(.body.monospacedDigit())
                    .frame(width: 50)
            }
        }
        .padding(16)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var standalonePlatformsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(S.detail.subProjectPlatforms, systemImage: "desktopcomputer")
                .font(.headline)

            if store.platforms.isEmpty {
                Text(S.detail.addSubProjectHint)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(store.platforms) { platform in
                        PlatformToggleTag(
                            platform: platform,
                            isSelected: subProject.platformIds.contains(platform.id),
                            onToggle: { store.togglePlatformInSubProject(platform.id, subProjectId: subProject.id) }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var standaloneLanguagesCard: some View {
        if !store.languages.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Label(S.detail.languages, systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(.headline)

                FlowLayout(spacing: 8) {
                    ForEach(store.languages) { language in
                        LanguageToggleTag(
                            language: language,
                            isSelected: subProject.languages.contains(language),
                            onToggle: { store.toggleLanguageInSubProject(language, subProjectId: subProject.id) }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private var standaloneLLMTagsCard: some View {
        if !store.llmTags.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Label(S.detail.llmTags, systemImage: "cpu")
                    .font(.headline)

                FlowLayout(spacing: 8) {
                    ForEach(store.llmTags) { tag in
                        LLMTagToggleTag(
                            tag: tag,
                            isSelected: subProject.llmTags.contains(tag),
                            onToggle: { store.toggleLLMTagInSubProject(tag, subProjectId: subProject.id) }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
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

struct LanguageToggleTag: View {
    let language: Language
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Text(language.displayName)
                    .font(.subheadline)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .primary : .secondary)
    }
}

struct LLMTagToggleTag: View {
    let tag: LLMTag
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Text(tag.displayName)
                    .font(.subheadline)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isSelected ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .primary : .secondary)
    }
}
