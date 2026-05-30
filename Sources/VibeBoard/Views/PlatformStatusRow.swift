import SwiftUI

struct PlatformStatusRow: View {
    @ObservedObject var store: VibeBoardStore
    @Binding var status: PlatformStatus
    var projectId: UUID

    private var platform: Platform? {
        store.platforms.first { $0.id == status.platformId }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: platform?.icon ?? "questionmark.square")
                .font(.title3)
                .foregroundStyle(status.isSupported ? .green : .secondary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(platform?.displayName ?? status.platformId)
                    .font(.headline)

                HStack(spacing: 8) {
                    TextField(S.detail.repoName, text: $status.repoName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 200)
                }
            }

            Spacer()

            Toggle(S.detail.implemented, isOn: $status.isSupported)
                .toggleStyle(.switch)
                .labelsHidden()

            if status.isSupported {
                ProgressView(value: status.progress)
                    .frame(width: 80)
                Text("\(Int(status.progress * 100))%")
                    .font(.caption)
                    .monospacedDigit()
                    .frame(width: 40)
            }

            Button(role: .destructive) {
                store.removePlatformStatusFromProject(status.platformId, projectId: projectId)
            } label: {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 6)
    }
}
