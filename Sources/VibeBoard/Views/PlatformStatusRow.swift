import SwiftUI

struct PlatformStatusRow: View {
    @ObservedObject var store: VibeBoardStore
    @Binding var status: PlatformStatus
    var projectId: UUID
    @State private var showDeleteConfirm = false

    private var platform: Platform? {
        store.platforms.first { $0.id == status.platformId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: platform?.icon ?? "questionmark.square")
                    .font(.title3)
                    .foregroundStyle(status.isSupported ? .green : .secondary)
                    .frame(width: 24)

                Text(platform?.displayName ?? status.platformId)
                    .font(.headline)

                Spacer()

                Toggle(S.detail.implemented, isOn: $status.isSupported)
                    .toggleStyle(.switch)

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .alert(S.detail.deletePlatformConfirmTitle, isPresented: $showDeleteConfirm) {
                    Button(S.detail.deleteGroup, role: .destructive) {
                        store.removePlatformStatusFromProject(status.platformId, projectId: projectId)
                    }
                    Button(S.sidebar.cancel, role: .cancel) {}
                } message: {
                    Text(S.detail.deletePlatformConfirmMessage)
                }
            }

            HStack(spacing: 12) {
                Label(S.detail.repoName, systemImage: "folder")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
                TextField(S.detail.repoName, text: $status.repoName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
            }

            if status.isSupported {
                HStack(spacing: 12) {
                    Label(S.detail.progress, systemImage: "chart.line.uptrend.xyaxis")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .trailing)
                    Slider(value: $status.progress, in: 0...1)
                        .frame(maxWidth: 200)
                    Text("\(Int(status.progress * 100))%")
                        .font(.caption.monospacedDigit())
                        .frame(width: 40)
                }
            }

            if !store.languages.isEmpty {
                HStack(alignment: .top, spacing: 12) {
                    Label(S.detail.languages, systemImage: "chevron.left.forwardslash.chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .trailing)
                        .padding(.top, 2)

                    FlowLayout(spacing: 6) {
                        ForEach(store.languages) { language in
                            LanguageToggleTag(
                                language: language,
                                isSelected: status.languages.contains(language),
                                onToggle: { store.toggleLanguageInPlatformStatus(language, platformId: status.platformId, projectId: projectId) }
                            )
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(status.isSupported ? Color.green.opacity(0.05) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(status.isSupported ? Color.green.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 0.5))
    }
}

struct LanguageToggleTag: View {
    let language: Language
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Text(language.displayName)
                    .font(.subheadline)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .primary : .secondary)
    }
}
