import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: VibeBoardStore
    @State private var showingNewProject = false

    var body: some View {
        List(selection: $store.selectedProjectId) {
            ForEach(store.projects) { project in
                ProjectRow(project: project, isSelected: store.selectedProjectId == project.id)
                    .tag(project.id)
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
                    "没有项目",
                    systemImage: "folder.badge.plus",
                    description: Text("点击 + 创建一个新项目")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingNewProject = true }) {
                    Label("新建项目", systemImage: "plus")
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
            Text("新建项目")
                .font(.headline)

            TextField("项目名称", text: $name)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("取消") { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Button("创建") {
                    let project = VibeProject(name: name, languages: [], platforms: store.enabledPlatforms)
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
