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
            HStack(spacing: 16) {
                statBadge(value: "\(supported)", label: S.detail.supported, color: .green)
                statBadge(value: "\(total - supported)", label: S.detail.notSupported, color: .orange)
                statBadge(value: "\(project.sharedGroups.count)", label: S.detail.sharedGroups, color: .blue)
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
        VStack(alignment: .leading, spacing: 14) {
            Label(S.detail.platformStatus, systemImage: "arrow.triangle.branch")
                .font(.title3.weight(.semibold))

            let sharedPlatformIds = Set(project.sharedGroups.flatMap(\.platformIds))

            if !project.sharedGroups.isEmpty {
                ForEach(project.sharedGroups) { group in
                    previewSharedGroupRow(group)
                }
            }

            let standaloneSupported = project.platformStatuses.filter { $0.isSupported && !sharedPlatformIds.contains($0.platformId) }
            let standaloneUnsupported = project.platformStatuses.filter { !$0.isSupported && !sharedPlatformIds.contains($0.platformId) }

            if !standaloneSupported.isEmpty {
                if !project.sharedGroups.isEmpty {
                    Divider().padding(.vertical, 4)
                }
                ForEach(standaloneSupported) { status in
                    previewPlatformRow(status)
                }
            }

            if !standaloneUnsupported.isEmpty {
                if !project.sharedGroups.isEmpty || !standaloneSupported.isEmpty {
                    Divider().padding(.vertical, 4)
                }
                ForEach(standaloneUnsupported) { status in
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

    private func previewSharedGroupRow(_ group: SharedGroup) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "square.on.square")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(Array(group.platformIds.enumerated()), id: \.offset) { index, pid in
                        let p = store.platforms.first { $0.id == pid }
                        if index > 0 {
                            Image(systemName: "plus")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: p?.icon ?? "questionmark.square")
                                .font(.body)
                            Text(p?.displayName ?? pid)
                                .font(.body.weight(.semibold))
                        }
                    }

                    if !group.name.isEmpty {
                        Text("- \(group.name)")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 6) {
                    if !group.repoName.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "folder")
                                .font(.caption)
                            Text(group.repoName)
                                .font(.callout)
                        }
                        .foregroundStyle(.secondary)
                    }

                    ForEach(group.languages.filter { store.validLanguageIds.contains($0.id) }) { lang in
                        Text(lang.displayName)
                            .font(.callout)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.tint.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    ForEach(group.llmTags.filter { store.validLLMTagIds.contains($0.id) }) { tag in
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

            if group.progress > 0 {
                VStack(spacing: 2) {
                    ProgressView(value: group.progress)
                        .frame(width: 80)
                    Text("\(Int(group.progress * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.blue.opacity(0.2), lineWidth: 1))
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
            editSharedGroupsCard
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

    private var editSharedGroupsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(S.detail.sharedGroups, systemImage: "square.on.square")
                    .font(.headline)

                Spacer()

                Button {
                    let group = SharedGroup(name: "", platformIds: [], repoName: "", languages: [])
                    store.addSharedGroup(group, projectId: project.id)
                } label: {
                    Label(S.detail.addSharedGroup, systemImage: "plus.circle")
                }
            }

            ForEach($project.sharedGroups) { $group in
                SharedGroupRow(store: store, group: $group, projectId: project.id)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
