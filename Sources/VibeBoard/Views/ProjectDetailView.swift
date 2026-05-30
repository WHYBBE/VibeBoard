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
        HStack(alignment: .bottom, spacing: 12) {
            if isEditing {
                TextField(S.detail.projectNamePlaceholder, text: $project.name)
                    .font(.title2.bold())
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(project.name)
                    .font(.title2.bold())
            }
            Spacer()

            let supported = project.platformStatuses.filter(\.isSupported).count
            let total = project.platformStatuses.count
            Text("\(supported)/\(total) \(S.detail.platformCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Preview

    private var previewContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            previewKeywordsCard
            previewUnifiedPlatformsCard
        }
    }

    private var previewKeywordsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(S.detail.keywords, systemImage: "tag.fill")
                .font(.headline)

            if project.keywords.isEmpty {
                Text(S.detail.noKeywords)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(project.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.tint.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var previewUnifiedPlatformsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(S.detail.platformStatus, systemImage: "arrow.triangle.branch")
                .font(.headline)

            let sharedPlatformIds = Set(project.sharedGroups.flatMap(\.platformIds))

            if !project.sharedGroups.isEmpty {
                VStack(alignment: .leading, spacing: 6) { }

                ForEach(project.sharedGroups) { group in
                    previewSharedGroupRow(group)
                }
            }

            let standaloneSupported = project.platformStatuses.filter { $0.isSupported && !sharedPlatformIds.contains($0.platformId) }
            let standaloneUnsupported = project.platformStatuses.filter { !$0.isSupported && !sharedPlatformIds.contains($0.platformId) }

            if !standaloneSupported.isEmpty {
                if !project.sharedGroups.isEmpty {
                    Divider().padding(.vertical, 2)
                }
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(standaloneSupported) { status in
                        previewPlatformRow(status)
                    }
                }
            }

            if !standaloneUnsupported.isEmpty {
                if !project.sharedGroups.isEmpty || !standaloneSupported.isEmpty {
                    Divider().padding(.vertical, 2)
                }
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(standaloneUnsupported) { status in
                        previewPlatformRow(status)
                    }
                    .opacity(0.6)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func previewSharedGroupRow(_ group: SharedGroup) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "square.on.square")
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    ForEach(Array(group.platformIds.enumerated()), id: \.offset) { index, pid in
                        let p = store.platforms.first { $0.id == pid }
                        if index > 0 {
                            Text("+")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 3) {
                            Image(systemName: p?.icon ?? "questionmark.square")
                                .font(.caption)
                            Text(p?.displayName ?? pid)
                                .font(.subheadline.weight(.medium))
                        }
                    }

                    if !group.name.isEmpty {
                        Text("- \(group.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 4) {
                    if !group.repoName.isEmpty {
                        Text(group.repoName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(group.languages) { lang in
                        Text(lang.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.tint.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            if group.progress > 0 {
                ProgressView(value: group.progress)
                    .frame(width: 60)
                Text("\(Int(group.progress * 100))%")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 36, alignment: .trailing)
            }
        }
        .padding(6)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func previewPlatformRow(_ status: PlatformStatus) -> some View {
        let platform = store.platforms.first { $0.id == status.platformId }

        return HStack(alignment: .center, spacing: 10) {
            Image(systemName: platform?.icon ?? "questionmark.square")
                .font(.body)
                .foregroundStyle(status.isSupported ? .green : .secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(platform?.displayName ?? status.platformId)
                        .font(.subheadline.weight(.medium))

                    if !status.repoName.isEmpty {
                        Text(status.repoName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if !status.languages.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(status.languages) { lang in
                            Text(lang.displayName)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.tint.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer()

            if status.isSupported, status.progress > 0 {
                ProgressView(value: status.progress)
                    .frame(width: 60)
                Text("\(Int(status.progress * 100))%")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 36, alignment: .trailing)
            }
        }
        .padding(.vertical, 4)
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
