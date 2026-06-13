import SwiftUI

struct ProjectDetailView: View {
    @ObservedObject var store: VibeBoardStore
    @Binding var project: VibeProject
    @State private var newKeyword: String = ""
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerBar
                if isEditing {
                    editContent
                } else {
                    previewContent
                }
            }
            .padding(20)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isEditing.toggle() }
                } label: {
                    Label(isEditing ? S.detail.preview : S.detail.edit, systemImage: isEditing ? "eye" : "pencil")
                }
                .toggleStyle(.button)
            }
        }
    }

    private var headerBar: some View {
        HStack(alignment: .bottom, spacing: 16) {
            if isEditing {
                TextField(S.detail.projectNamePlaceholder, text: $project.name)
                    .font(.title.bold())
                    .textFieldStyle(.roundedBorder)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.title.bold())
                    Text(project.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()

            let supported = project.platformStatuses.filter(\.isSupported).count
            let total = project.platformStatuses.count
            let subCount = project.subProjectIds.count
            HStack(spacing: 16) {
                statBadge(value: "\(supported)", label: S.detail.supported, color: .green)
                statBadge(value: "\(total - supported)", label: S.detail.notSupported, color: .orange)
                statBadge(value: "\(subCount)", label: S.detail.subProjects, color: .orange)
            }
        }
    }

    private func statBadge(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 56)
    }

    // MARK: - Preview

    private var previewContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            previewKeywordsCard
            previewUnifiedPlatformsCard
        }
    }

    private var previewKeywordsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(S.detail.keywords, systemImage: "tag.fill")
                .font(.title3.weight(.semibold))

            if project.keywords.isEmpty {
                Text(S.detail.noKeywords)
                    .font(.body)
                    .foregroundStyle(.tertiary)
            } else {
                FlowLayout(spacing: 10) {
                    ForEach(project.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.body)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(.tint.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var previewUnifiedPlatformsCard: some View {
        let boundSubs = store.subProjects.filter { project.subProjectIds.contains($0.id) }

        return VStack(alignment: .leading, spacing: 14) {
            Label(S.detail.platformStatus, systemImage: "arrow.triangle.branch")
                .font(.title3.weight(.semibold))

            if !boundSubs.isEmpty {
                ForEach(boundSubs) { sub in
                    previewSubProjectRow(sub)
                }
            }

            let supported = project.platformStatuses.filter(\.isSupported)
            let unsupported = project.platformStatuses.filter { !$0.isSupported }

            if !supported.isEmpty {
                if !boundSubs.isEmpty { Divider().padding(.vertical, 4) }
                ForEach(supported) { status in
                    previewPlatformRow(status)
                }
            }

            if !unsupported.isEmpty {
                if !boundSubs.isEmpty || !supported.isEmpty { Divider().padding(.vertical, 4) }
                ForEach(unsupported) { status in
                    previewPlatformRow(status)
                }
                .opacity(0.5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func previewSubProjectRow(_ sub: SubProject) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "cube.box")
                .font(.title2)
                .foregroundStyle(.orange)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(sub.name)
                        .font(.body.weight(.semibold))

                    if !sub.repoName.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "folder")
                                .font(.caption)
                            Text(sub.repoName)
                                .font(.callout)
                        }
                        .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 4) {
                    ForEach(sub.platformIds, id: \.self) { pid in
                        let p = store.platforms.first { $0.id == pid }
                        Image(systemName: p?.icon ?? "questionmark.square")
                            .font(.caption)
                    }

                    ForEach(sub.languages.filter { store.validLanguageIds.contains($0.id) }) { lang in
                        Text(lang.displayName)
                            .font(.callout)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.tint.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    ForEach(sub.llmTags.filter { store.validLLMTagIds.contains($0.id) }) { tag in
                        Text(tag.displayName)
                            .font(.callout)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.purple.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            if sub.progress > 0 {
                VStack(spacing: 2) {
                    ProgressView(value: sub.progress)
                        .frame(width: 80)
                    Text("\(Int(sub.progress * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.orange.opacity(0.2), lineWidth: 1))
    }

    private func previewPlatformRow(_ status: PlatformStatus) -> some View {
        let platform = store.platforms.first { $0.id == status.platformId }

        return HStack(alignment: .center, spacing: 14) {
            Image(systemName: platform?.icon ?? "questionmark.square")
                .font(.title2)
                .foregroundStyle(status.isSupported ? .green : .secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(platform?.displayName ?? status.platformId)
                        .font(.body.weight(.semibold))

                    if !status.repoName.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "folder")
                                .font(.caption)
                            Text(status.repoName)
                                .font(.callout)
                        }
                        .foregroundStyle(.secondary)
                    }
                }

                if !status.languages.isEmpty || !status.llmTags.filter({ store.validLLMTagIds.contains($0.id) }).isEmpty {
                    HStack(spacing: 6) {
                        ForEach(status.languages.filter { store.validLanguageIds.contains($0.id) }) { lang in
                            Text(lang.displayName)
                                .font(.callout)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.tint.opacity(0.12))
                                .clipShape(Capsule())
                        }

                        ForEach(status.llmTags.filter { store.validLLMTagIds.contains($0.id) }) { tag in
                            Text(tag.displayName)
                                .font(.callout)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.purple.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer()

            if status.isSupported, status.progress > 0 {
                VStack(spacing: 2) {
                    ProgressView(value: status.progress)
                        .frame(width: 80)
                    Text("\(Int(status.progress * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Edit

    private var editContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            editKeywordsCard
            editSubProjectsCard
            editPlatformsCard
        }
    }

    private var editKeywordsCard: some View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var editSubProjectsCard: some View {
        let boundSubs = store.subProjects.filter { project.subProjectIds.contains($0.id) }

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(S.detail.subProjects, systemImage: "cube.box")
                    .font(.headline)

                Spacer()

                Menu {
                    ForEach(store.unboundSubProjects) { sub in
                        Button(sub.name) {
                            store.bindSubProject(sub.id, toProject: project.id)
                        }
                    }
                    Divider()
                    Button(S.detail.newSubProject) {
                        let sub = SubProject(name: "")
                        store.addSubProject(sub)
                        store.bindSubProject(sub.id, toProject: project.id)
                    }
                } label: {
                    Label(S.detail.addSubProject, systemImage: "plus.circle")
                }
            }

            if boundSubs.isEmpty {
                Text(S.detail.addSubProject)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(boundSubs) { sub in
                    editSubProjectRow(sub)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func editSubProjectRow(_ sub: SubProject) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "cube.box")
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 6) {
                Text(sub.name.isEmpty ? S.detail.subProjectName : sub.name)
                    .font(.headline)

                HStack(spacing: 4) {
                    ForEach(sub.platformIds, id: \.self) { pid in
                        let p = store.platforms.first { $0.id == pid }
                        Image(systemName: p?.icon ?? "questionmark.square")
                            .font(.caption)
                    }

                    ForEach(sub.languages) { lang in
                        Text(lang.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(.tint.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    ForEach(sub.llmTags.filter { store.validLLMTagIds.contains($0.id) }) { tag in
                        Text(tag.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.purple.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    if !sub.repoName.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "folder")
                                .font(.caption2)
                            Text(sub.repoName)
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }

                    if sub.progress > 0 {
                        Text("\(Int(sub.progress * 100))%")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button(S.detail.unbind) {
                store.unbindSubProject(sub.id, fromProject: project.id)
            }
            .controlSize(.small)
        }
        .padding(10)
        .background(Color.orange.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.orange.opacity(0.3), lineWidth: 0.5))
    }

    private var editPlatformsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(S.detail.platformStatus, systemImage: "arrow.triangle.branch")
                    .font(.headline)

                Spacer()

                Menu {
                    ForEach(store.platforms.filter { p in
                        !project.platformStatuses.contains(where: { $0.platformId == p.id })
                    }) { platform in
                        Button(platform.displayName) {
                            store.addPlatformStatusToProject(platform, projectId: project.id)
                        }
                    }
                } label: {
                    Label(S.detail.addPlatform, systemImage: "plus.circle")
                }
                .disabled(store.platforms.filter { p in
                    !project.platformStatuses.contains(where: { $0.platformId == p.id })
                }.isEmpty)
            }

            ForEach($project.platformStatuses) { $status in
                PlatformStatusRow(store: store, status: $status, projectId: project.id)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func addKeyword() {
        let trimmed = newKeyword.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.addKeyword(trimmed, projectId: project.id)
        newKeyword = ""
    }
}
