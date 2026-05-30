import SwiftUI

public struct VibeBoardView: View {
    @ObservedObject var store: VibeBoardStore

    public init(store: VibeBoardStore) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView {
            SidebarView(store: store)
        } detail: {
            if let selectedId = store.selectedProjectId,
               let index = store.projects.firstIndex(where: { $0.id == selectedId }) {
                ProjectDetailView(store: store, project: $store.projects[index])
            } else {
                ContentUnavailableView(
                    "选择一个项目",
                    systemImage: "arrow.left",
                    description: Text("从左侧选择或创建一个项目")
                )
            }
        }
    }
}
