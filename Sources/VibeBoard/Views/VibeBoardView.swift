import SwiftUI

enum SidebarMode: String, CaseIterable {
    case projects, subProjects, overview
}

public struct VibeBoardView: View {
    @ObservedObject var store: VibeBoardStore
    @State private var sidebarMode: SidebarMode = {
        if let raw = UserDefaults.standard.string(forKey: "sidebarMode"),
           let mode = SidebarMode(rawValue: raw) {
            return mode
        }
        return .projects
    }()
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    public init(store: VibeBoardStore) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebarContent
        } detail: {
            detailContent
        }
        .navigationSplitViewColumnWidth(250)
        .sheet(isPresented: $showingNewProject) {
            NewProjectSheet(store: store)
        }
        .sheet(isPresented: $showingNewSubProject) {
            NewSubProjectSheet(store: store)
        }
        .onChange(of: sidebarMode) { _, newValue in
            UserDefaults.standard.set(newValue.rawValue, forKey: "sidebarMode")
            withAnimation(.none) {
                columnVisibility = newValue == .overview ? .detailOnly : .all
            }
            if newValue == .overview {
                store.selectedProjectId = nil
                store.selectedSubProjectId = nil
            }
        }
        .onChange(of: columnVisibility) { _, newValue in
            if sidebarMode == .overview && newValue != .detailOnly {
                sidebarMode = .projects
            }
        }
        .onAppear {
            columnVisibility = sidebarMode == .overview ? .detailOnly : .all
        }
    }

    @State private var showingNewProject = false
    @State private var showingNewSubProject = false

    // MARK: - Sidebar

    private var sidebarContent: some View {
        Group {
            switch sidebarMode {
            case .projects:
                projectSidebar
            case .subProjects:
                subProjectSidebar
            case .overview:
                EmptyView()
            }
        }
    }

    private var projectSidebar: some View {
        List(selection: $store.selectedProjectId) {
            ForEach(store.projects) { project in
                ProjectRow(project: project, isSelected: store.selectedProjectId == project.id, subProjectCount: store.subProjects(forProject: project.id).count)
                    .tag(project.id)
                    .contextMenu {
                        Button(role: .destructive) {
                            projectToDelete = project.id
                            showDeleteProjectConfirm = true
                        } label: {
                            Label(S.sidebar.deleteProject, systemImage: "trash")
                        }
                    }
            }
            .onDelete { indexSet in
                if indexSet.count == 1, let index = indexSet.first {
                    projectToDelete = store.projects[index].id
                    showDeleteProjectConfirm = true
                } else {
                    for index in indexSet {
                        store.deleteProject(store.projects[index].id)
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
            .padding(.vertical, 6)
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
        .alert(S.sidebar.deleteProjectConfirmTitle, isPresented: $showDeleteProjectConfirm) {
            Button(S.sidebar.deleteProject, role: .destructive) {
                if let id = projectToDelete { store.deleteProject(id) }
                projectToDelete = nil
            }
            Button(S.sidebar.cancel, role: .cancel) { projectToDelete = nil }
        } message: {
            Text(S.sidebar.deleteProjectConfirmMessage)
        }
    }

    private enum SidebarGroupBy: String, CaseIterable {
        case none, platform, language
    }

    @State private var groupBy: SidebarGroupBy = {
        if let raw = UserDefaults.standard.string(forKey: "sidebarGroupBy"),
           let mode = SidebarGroupBy(rawValue: raw) {
            return mode
        }
        return .none
    }()

    private func iconForGroupBy(_ mode: SidebarGroupBy) -> String {
        switch mode {
        case .platform: return "desktopcomputer"
        case .language: return "chevron.left.forwardslash.chevron.right"
        case .none: return "list.bullet"
        }
    }

    @State private var projectToDelete: UUID?
    @State private var showDeleteProjectConfirm = false

    private var subProjectSidebar: some View {
        List(selection: $store.selectedSubProjectId) {
            ForEach(store.subProjects) { sub in
                HStack(spacing: 8) {
                    Image(systemName: "cube.box")
                        .foregroundStyle(.orange)
                    Text(sub.name)
                        .lineLimit(1)
                    Spacer()
                    if !sub.platformIds.isEmpty {
                        ForEach(sub.platformIds.prefix(3), id: \.self) { pid in
                            let p = store.platforms.first { $0.id == pid }
                            Image(systemName: p?.icon ?? "questionmark.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .tag(sub.id)
                .contextMenu {
                    Button(role: .destructive) {
                        subProjectToDelete = sub.id
                        showDeleteSubProjectConfirm = true
                    } label: {
                        Label(S.detail.deleteSubProjectConfirmTitle, systemImage: "trash")
                    }
                }
            }
            .onDelete { indexSet in
                if indexSet.count == 1, let index = indexSet.first {
                    subProjectToDelete = store.subProjects[index].id
                    showDeleteSubProjectConfirm = true
                } else {
                    for index in indexSet {
                        store.deleteSubProject(store.subProjects[index].id)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .overlay {
            if store.subProjects.isEmpty {
                ContentUnavailableView(
                    S.detail.addSubProject,
                    systemImage: "cube.box",
                    description: Text(S.detail.newSubProject)
                )
            }
        }
        .alert(S.detail.deleteSubProjectConfirmTitle, isPresented: $showDeleteSubProjectConfirm) {
            Button(S.detail.deleteSubProjectConfirmTitle, role: .destructive) {
                if let id = subProjectToDelete { store.deleteSubProject(id) }
                subProjectToDelete = nil
            }
            Button(S.sidebar.cancel, role: .cancel) { subProjectToDelete = nil }
        } message: {
            Text(S.detail.deleteSubProjectConfirmMessage)
        }
    }

    @State private var subProjectToDelete: UUID?
    @State private var showDeleteSubProjectConfirm = false

    // MARK: - Detail

    @ViewBuilder
    private var detailContent: some View {
        Group {
            switch sidebarMode {
            case .projects:
                if let selectedId = store.selectedProjectId,
                   let index = store.projects.firstIndex(where: { $0.id == selectedId }) {
                    ProjectDetailView(store: store, project: $store.projects[index])
                } else {
                    ContentUnavailableView(
                        S.detail.selectProject,
                        systemImage: "arrow.left",
                        description: Text(S.detail.selectProjectHint)
                    )
                }
            case .subProjects:
                if let selectedId = store.selectedSubProjectId,
                   let index = store.subProjects.firstIndex(where: { $0.id == selectedId }) {
                    SubProjectRow(store: store, subProject: $store.subProjects[index], projectId: nil, standalone: true)
                } else {
                    ContentUnavailableView(
                        S.detail.addSubProject,
                        systemImage: "cube.box",
                        description: Text(S.detail.newSubProject)
                    )
                }
            case .overview:
                OverviewView(store: store, onProjectTap: { id in
                    store.selectedProjectId = id
                    sidebarMode = .projects
                })
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker(selection: $sidebarMode) {
                    ForEach(SidebarMode.allCases, id: \.self) { mode in
                        Image(systemName: iconForMode(mode))
                            .tag(mode)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
            ToolbarItem(placement: .primaryAction) {
                if sidebarMode == .projects {
                    Button(action: { showingNewProject = true }) {
                        Label(S.sidebar.newProject, systemImage: "plus")
                    }
                } else if sidebarMode == .subProjects {
                    Button(action: { showingNewSubProject = true }) {
                        Label(S.detail.newSubProject, systemImage: "plus")
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func iconForMode(_ mode: SidebarMode) -> String {
        switch mode {
        case .projects: return "folder"
        case .subProjects: return "cube.box"
        case .overview: return "square.grid.2x2"
        }
    }
}

struct NewSubProjectSheet: View {
    @ObservedObject var store: VibeBoardStore
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var repoURL: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text(S.detail.newSubProject)
                .font(.headline)

            TextField(S.detail.subProjectName, text: $name)
                .textFieldStyle(.roundedBorder)

            TextField(S.detail.repoURL, text: $repoURL)
                .textFieldStyle(.roundedBorder)
                .onChange(of: repoURL) { _, newValue in
                    if name.trimmingCharacters(in: .whitespaces).isEmpty {
                        name = parseRepoName(from: newValue)
                    }
                }

            HStack {
                Button(S.sidebar.cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Button(S.sidebar.create) {
                    let sub = SubProject(name: name, repoURL: repoURL)
                    store.addSubProject(sub)
                    store.selectedSubProjectId = sub.id
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }

    private func parseRepoName(from url: String) -> String {
        guard let last = url.split(separator: "/").last else { return name }
        let result = last.hasSuffix(".git") ? String(last.dropLast(4)) : String(last)
        return result.trimmingCharacters(in: .whitespaces)
    }
}
