import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: VibeBoardStore
    @State private var showingNewProject = false
    @State private var projectToDelete: UUID?
    @State private var showDeleteConfirm = false
    @State private var groupBy: SidebarGroupBy = {
        if let raw = UserDefaults.standard.string(forKey: "sidebarGroupBy"),
           let mode = SidebarGroupBy(rawValue: raw) {
            return mode
        }
        return .none
    }()

    private enum SidebarGroupBy: String, CaseIterable {
        case none, platform, language
    }

    private struct SidebarTag: Hashable {
        let groupId: String
        let projectId: UUID
    }

    private var currentTag: SidebarTag? {
        guard let id = store.selectedProjectId else { return nil }
        switch groupBy {
        case .none:
            return SidebarTag(groupId: "", projectId: id)
        case .platform:
            guard let project = store.projects.first(where: { $0.id == id }) else { return nil }
            let firstPlatform = project.platformStatuses.first(where: { $0.isSupported })?.platformId ?? ""
            return SidebarTag(groupId: firstPlatform, projectId: id)
        case .language:
            guard let project = store.projects.first(where: { $0.id == id }) else { return nil }
            let firstLang = project.platformStatuses.flatMap(\.languages).first?.id ?? ""
            return SidebarTag(groupId: firstLang, projectId: id)
        }
    }

    var body: some View {
        List(selection: $sidebarSelection) {
            switch groupBy {
            case .platform:
                ForEach(store.platforms) { platform in
                    let projects = store.projects.filter { p in
                        p.platformStatuses.contains(where: { $0.platformId == platform.id })
                    }
                    if !projects.isEmpty {
                        Section(platform.displayName) {
                            ForEach(projects) { project in
                                ProjectRow(project: project, isSelected: store.selectedProjectId == project.id)
                                    .tag(SidebarTag(groupId: platform.id, projectId: project.id))
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            projectToDelete = project.id
                                            showDeleteConfirm = true
                                        } label: {
                                            Label(S.sidebar.deleteProject, systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            case .language:
                ForEach(store.languages) { language in
                    let projects = store.projects.filter { p in
                        p.platformStatuses.contains(where: { $0.languages.contains(language) })
                    }
                    if !projects.isEmpty {
                        Section(language.displayName) {
                            ForEach(projects) { project in
                                ProjectRow(project: project, isSelected: store.selectedProjectId == project.id)
                                    .tag(SidebarTag(groupId: language.id, projectId: project.id))
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            projectToDelete = project.id
                                            showDeleteConfirm = true
                                        } label: {
                                            Label(S.sidebar.deleteProject, systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            case .none:
                ForEach(store.projects) { project in
                    ProjectRow(project: project, isSelected: store.selectedProjectId == project.id)
                        .tag(SidebarTag(groupId: "", projectId: project.id))
                        .contextMenu {
                            Button(role: .destructive) {
                                projectToDelete = project.id
                                showDeleteConfirm = true
                            } label: {
                                Label(S.sidebar.deleteProject, systemImage: "trash")
                            }
                        }
                }
                .onDelete { indexSet in
                    if indexSet.count == 1, let index = indexSet.first {
                        projectToDelete = store.projects[index].id
                        showDeleteConfirm = true
                    } else {
                        for index in indexSet {
                            store.deleteProject(store.projects[index].id)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            Picker(selection: $groupBy) {
                ForEach(SidebarGroupBy.allCases, id: \.self) { mode in
                    Image(systemName: iconForGroupBy(mode))
                        .tag(mode)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)
        }
        .overlay {
            if store.projects.isEmpty {
                ContentUnavailableView(
                    S.sidebar.noProject,
                    systemImage: "folder.badge.plus",
                    description: Text(S.sidebar.noProjectHint)
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingNewProject = true }) {
                    Label(S.sidebar.newProject, systemImage: "plus")
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                if store.selectedProjectId != nil {
                    Button(role: .destructive) {
                        projectToDelete = store.selectedProjectId
                        showDeleteConfirm = true
                    } label: {
                        Label(S.sidebar.deleteProject, systemImage: "minus")
                    }
                }
            }
        }
        .alert(S.sidebar.deleteProjectConfirmTitle, isPresented: $showDeleteConfirm) {
            Button(S.sidebar.deleteProject, role: .destructive) {
                if let id = projectToDelete { store.deleteProject(id) }
                projectToDelete = nil
            }
            Button(S.sidebar.cancel, role: .cancel) {
                projectToDelete = nil
            }
        } message: {
            Text(S.sidebar.deleteProjectConfirmMessage)
        }
        .sheet(isPresented: $showingNewProject) {
            NewProjectSheet(store: store)
        }
        .onChange(of: sidebarSelection) { _, newTag in
            if let newTag {
                store.selectedProjectId = newTag.projectId
            }
        }
        .onChange(of: groupBy) { _, newMode in
            sidebarSelection = currentTag
            UserDefaults.standard.set(newMode.rawValue, forKey: "sidebarGroupBy")
        }
    }

    @State private var sidebarSelection: SidebarTag?

    private func labelForGroupBy(_ mode: SidebarGroupBy) -> String {
        switch mode {
        case .platform: return S.sidebar.groupByPlatform
        case .language: return S.sidebar.groupByLanguage
        case .none: return S.sidebar.groupByNone
        }
    }

    private func iconForGroupBy(_ mode: SidebarGroupBy) -> String {
        switch mode {
        case .platform: return "desktopcomputer"
        case .language: return "chevron.left.forwardslash.chevron.right"
        case .none: return "list.bullet"
        }
    }
}

struct NewProjectSheet: View {
    @ObservedObject var store: VibeBoardStore
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text(S.sidebar.newProject)
                .font(.headline)

            TextField(S.sidebar.projectName, text: $name)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button(S.sidebar.cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Button(S.sidebar.create) {
                    let project = VibeProject(name: name, platforms: store.enabledPlatforms)

                    store.addProject(project)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
