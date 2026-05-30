import SwiftUI

struct ProjectDetailView: View {
    @ObservedObject var store: VibeBoardStore
    @Binding var project: VibeProject
    @State private var newKeyword: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                projectNameSection
                keywordsSection
                languagesSection
                platformStatusesSection
            }
            .padding()
        }
    }

    private var projectNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(S.detail.projectName, systemImage: "folder.fill")
                .font(.headline)
            TextField(S.detail.projectNamePlaceholder, text: $project.name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var keywordsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(S.detail.keywords, systemImage: "tag.fill")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(project.keywords, id: \.self) { keyword in
                    KeywordTag(keyword: keyword) {
                        store.removeKeyword(keyword, projectId: project.id)
                    }
                }
            }

            HStack {
                TextField(S.detail.addKeyword, text: $newKeyword)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addKeyword() }

                Button(S.detail.add, action: addKeyword)
                    .disabled(newKeyword.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private var languagesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(S.detail.languages, systemImage: "text.code")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(store.enabledLanguages) { language in
                    LanguageToggleTag(
                        language: language,
                        isSelected: project.languages.contains(language),
                        onToggle: { store.toggleLanguageInProject(language, projectId: project.id) }
                    )
                }
            }
        }
    }

    private var platformStatusesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(S.detail.platformStatus, systemImage: "arrow.triangle.branch")
                    .font(.headline)

                Spacer()

                Menu {
                    ForEach(store.enabledPlatforms.filter { p in
                        !project.platformStatuses.contains(where: { $0.platformId == p.id })
                    }) { platform in
                        Button(platform.displayName) {
                            store.addPlatformStatusToProject(platform, projectId: project.id)
                        }
                    }
                } label: {
                    Label(S.detail.addPlatform, systemImage: "plus.circle")
                }
                .disabled(store.enabledPlatforms.filter { p in
                    !project.platformStatuses.contains(where: { $0.platformId == p.id })
                }.isEmpty)
            }

            ForEach($project.platformStatuses) { $status in
                PlatformStatusRow(store: store, status: $status, projectId: project.id)
            }
        }
    }

    private func addKeyword() {
        let trimmed = newKeyword.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.addKeyword(trimmed, projectId: project.id)
        newKeyword = ""
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
