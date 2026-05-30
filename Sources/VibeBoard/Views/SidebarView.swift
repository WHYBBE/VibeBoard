import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: VibeBoardStore
    @State private var showingNewProject = false

    var body: some View {
        List(selection: $store.selectedProjectId) {
            ForEach(store.projects) { project in
                ProjectRow(project: project, isSelected: store.selectedProjectId == project.id)
                    .tag(project.id)
                    .contextMenu {
                        Button(role: .destructive) {
                            store.deleteProject(project.id)
                        } label: {
                            Label(S.sidebar.deleteProject, systemImage: "trash")
                        }
                    }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    store.deleteProject(store.projects[index].id)
                }
            }
        }
        .listStyle(.sidebar)
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
                        if let id = store.selectedProjectId { store.deleteProject(id) }
                    } label: {
                        Label(S.sidebar.deleteProject, systemImage: "minus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewProject) {
            NewProjectSheet(store: store)
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
                    let project = VibeProject(name: name, platforms: store.platforms)

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
