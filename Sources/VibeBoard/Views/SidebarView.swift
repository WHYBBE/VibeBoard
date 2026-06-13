import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: VibeBoardStore

    var body: some View {
        List(selection: $store.selectedProjectId) {
            ForEach(store.projects) { project in
                ProjectRow(project: project, isSelected: store.selectedProjectId == project.id)
                    .tag(project.id)
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
        .alert(S.sidebar.deleteProjectConfirmTitle, isPresented: $showDeleteConfirm) {
            Button(S.sidebar.deleteProject, role: .destructive) {
                if let id = projectToDelete { store.deleteProject(id) }
                projectToDelete = nil
            }
            Button(S.sidebar.cancel, role: .cancel) { projectToDelete = nil }
        } message: {
            Text(S.sidebar.deleteProjectConfirmMessage)
        }
    }

    @State private var projectToDelete: UUID?
    @State private var showDeleteConfirm = false
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
                    let project = VibeProject(name: name, platformStatuses: store.enabledPlatforms.map { PlatformStatus(platform: $0, isSupported: $0.isEnabled) })
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
