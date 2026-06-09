import SwiftUI

public struct VibeBoardView: View {
    @ObservedObject var store: VibeBoardStore
    @State private var isOverviewMode: Bool = {
        let mode = UserDefaults.standard.bool(forKey: "isOverviewMode") != false
        return mode
    }()
    @State private var columnVisibility: NavigationSplitViewVisibility = {
        UserDefaults.standard.bool(forKey: "isOverviewMode") != false ? .detailOnly : .all
    }()

    public init(store: VibeBoardStore) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(store: store)
        } detail: {
            if isOverviewMode {
                OverviewView(store: store, onProjectTap: { id in
                    store.selectedProjectId = id
                    isOverviewMode = false
                })
            } else if let selectedId = store.selectedProjectId,
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
        .navigationSplitViewColumnWidth(250)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isOverviewMode.toggle()
                } label: {
                    Label(
                        isOverviewMode ? S.sidebar.projects : S.sidebar.overview,
                        systemImage: isOverviewMode ? "list.bullet" : "square.grid.2x2"
                    )
                }
            }
        }
        .onChange(of: isOverviewMode) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "isOverviewMode")
            columnVisibility = newValue ? .detailOnly : .all
        }
        .onChange(of: columnVisibility) { _, newValue in
            if isOverviewMode && newValue != .detailOnly {
                isOverviewMode = false
            }
        }
        .onAppear {
            columnVisibility = isOverviewMode ? .detailOnly : .all
        }
    }
}
