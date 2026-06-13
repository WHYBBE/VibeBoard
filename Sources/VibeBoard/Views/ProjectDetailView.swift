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

            let boundSubs = store.subProjects.filter { project.subProjectIds.contains($0.id) }
            let supported = boundSubs.filter(\.isSupported).count
            let shared = boundSubs.filter(\.isShared).count
            HStack(spacing: 16) {
                statBadge(value: "\(supported)", label: S.detail.supported, color: .green)
                statBadge(value: "\(boundSubs.count - supported)", label: S.detail.notSupported, color: .orange)
                statBadge(value: "\(shared)", label: S.detail.shared, color: .blue)
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
            previewSubProjectsCard
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

    private var previewSubProjectsCard: some View {
        let boundSubs = store.subProjects.filter { project.subProjectIds.contains($0.id) }
        let sharedSubs = boundSubs.filter(\.isShared)
        let singleSubs = boundSubs.filter { !$0.isShared }

        return VStack(alignment: .leading, spacing: 14) {
            Label(S.detail.platformStatus, systemImage: "cube.box")
                .font(.title3.weight(.semibold))

            if boundSubs.isEmpty {
                Text(S.detail.noSubProjects)
                    .font(.body)
                    .foregroundStyle(.tertiary)
            } else {
                if !sharedSubs.isEmpty {
                    Label(S.detail.shared, systemImage: "link")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.blue)

                    ForEach(sharedSubs) { sub in
                        previewSubProjectRow(sub)
                    }

                    if !singleSubs.isEmpty {
                        Divider().padding(.vertical, 4)
                    }
                }

                if !singleSubs.isEmpty {
                    ForEach(singleSubs) { sub in
                        previewSubProjectRow(sub)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func previewSubProjectRow(_ sub: SubProject) -> some View {
        HStack(alignment: .center, spacing: 14) {
            subProjectIcon(sub)
            subProjectInfo(sub)
            Spacer()
            if sub.isSupported, sub.progress > 0 {
                subProjectProgress(sub)
            }
        }
        .padding(12)
        .background(sub.isShared ? Color.blue.opacity(0.04) : (sub.isSupported ? Color.green.opacity(0.04) : Color.clear))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(
            sub.isShared ? Color.blue.opacity(0.2) : (sub.isSupported ? Color.green.opacity(0.15) : Color.gray.opacity(0.2)),
            lineWidth: 1
        ))
    }

    private func subProjectIcon(_ sub: SubProject) -> some View {
        Image(systemName: sub.isShared ? "link.circle.fill" : "cube.box")
            .font(.title2)
            .foregroundStyle(sub.isShared ? .blue : (sub.isSupported ? .green : .secondary))
            .frame(width: 28)
    }

    @ViewBuilder
    private func subProjectInfo(_ sub: SubProject) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(sub.name.isEmpty ? S.detail.subProjectName : sub.name)
                    .font(.body.weight(.semibold))
                if !sub.repoURL.isEmpty {
                    Link(destination: URL(string: sub.repoURL) ?? URL(string: "https://example.com")!) {
                        HStack(spacing: 3) {
                            Image(systemName: "link").font(.caption)
                            Text(sub.repoURL).font(.callout).lineLimit(1)
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
            HStack(spacing: 4) {
                subProjectPlatformTags(sub)
                subProjectLanguageTags(sub)
                subProjectLLMTags(sub)
            }
        }
    }

    @ViewBuilder
    private func subProjectPlatformTags(_ sub: SubProject) -> some View {
        ForEach(sub.platformIds, id: \.self) { pid in
            let p = store.platforms.first { $0.id == pid }
            HStack(spacing: 3) {
                Image(systemName: p?.icon ?? "questionmark.square").font(.caption)
                if sub.isShared {
                    Text(p?.displayName ?? pid).font(.caption2)
                }
            }
            .padding(.horizontal, sub.isShared ? 6 : 4)
            .padding(.vertical, 2)
            .background(sub.isShared ? Color.blue.opacity(0.12) : Color.clear)
            .clipShape(Capsule())
        }
        if sub.platformIds.isEmpty {
            Text(S.detail.platformOnly)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private func subProjectLanguageTags(_ sub: SubProject) -> some View {
        ForEach(sub.languages.filter { store.validLanguageIds.contains($0.id) }) { lang in
            Text(lang.displayName)
                .font(.callout)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.tint.opacity(0.12))
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private func subProjectLLMTags(_ sub: SubProject) -> some View {
        ForEach(sub.llmTags.filter { store.validLLMTagIds.contains($0.id) }) { tag in
            Text(tag.displayName)
                .font(.callout)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.purple.opacity(0.12))
                .clipShape(Capsule())
        }
    }

    private func subProjectProgress(_ sub: SubProject) -> some View {
        VStack(spacing: 2) {
            ProgressView(value: sub.progress).frame(width: 80)
            Text("\(Int(sub.progress * 100))%")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Edit

    private var editContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            editKeywordsCard
            editSubProjectsCard
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
                Label(S.detail.platformStatus, systemImage: "cube.box")
                    .font(.headline)

                Spacer()

                Menu {
                    Button(S.detail.newSubProject) {
                        let sub = SubProject(name: "")
                        store.addSubProjectToProject(sub, projectId: project.id)
                    }

                    Button(S.detail.createForPlatforms) {
                        for platform in store.enabledPlatforms {
                            let existing = boundSubs.first { $0.platformIds == [platform.id] }
                            if existing == nil {
                                let sub = SubProject(
                                    name: platform.displayName,
                                    platformIds: [platform.id],
                                    isSupported: true
                                )
                                store.addSubProjectToProject(sub, projectId: project.id)
                            }
                        }
                    }

                    Divider()

                    ForEach(store.unboundSubProjects) { sub in
                        Button(sub.name) {
                            store.bindSubProject(sub.id, toProject: project.id)
                        }
                    }
                } label: {
                    Label(S.detail.addSubProject, systemImage: "plus.circle")
                }
            }

            if boundSubs.isEmpty {
                Text(S.detail.addSubProjectHint)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(boundSubs) { sub in
                    if let index = store.subProjects.firstIndex(where: { $0.id == sub.id }) {
                        SubProjectRow(store: store, subProject: $store.subProjects[index], projectId: project.id)
                    }
                }
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
