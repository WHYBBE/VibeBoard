import SwiftUI

struct PlatformStatusRow: View {
    @ObservedObject var store: VibeBoardStore
    @Binding var status: PlatformStatus
    var projectId: UUID

    private var platform: Platform? {
        store.platforms.first { $0.id == status.platformId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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

            if !store.enabledLanguages.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(store.enabledLanguages) { language in
                        LanguageToggleTag(
                            language: language,
                            isSelected: status.languages.contains(language),
                            onToggle: { store.toggleLanguageInPlatformStatus(language, platformId: status.platformId, projectId: projectId) }
                        )
                    }
                }
            }
        }
        .padding(.vertical, 6)
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
