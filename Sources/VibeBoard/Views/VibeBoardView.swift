import SwiftUI

public struct VibeBoardView: View {
    @ObservedObject var store: VibeBoardStore
    @State private var isOverviewMode = true
    @State private var showingNewProject = false

    public init(store: VibeBoardStore) {
        self.store = store
    }

    public var body: some View {
        Group {
            if isOverviewMode {
                OverviewView(store: store, onProjectTap: { id in
                    store.selectedProjectId = id
                    withAnimation(.easeInOut(duration: 0.2)) { isOverviewMode = false }
                })
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { showingNewProject = true }) {
                            Label(S.sidebar.newProject, systemImage: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigation) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { isOverviewMode = false }
                        } label: {
                            Label(S.sidebar.projects, systemImage: "sidebar.left")
                        }
                    }
                }
            } else {
                projectSplitView
            }
        }
        .sheet(isPresented: $showingNewProject) {
            NewProjectSheet(store: store)
        }
    }

    private var projectSplitView: some View {
        NavigationSplitView {
            SidebarView(store: store)
        } detail: {
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
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isOverviewMode = true }
                } label: {
                    Label(S.sidebar.overview, systemImage: "square.grid.2x2")
                }
            }
        }
    }
}
