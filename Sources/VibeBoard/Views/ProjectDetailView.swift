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
