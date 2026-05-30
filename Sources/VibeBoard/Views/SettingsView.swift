import SwiftUI

public struct SettingsView: View {
    @ObservedObject var store: VibeBoardStore

    public init(store: VibeBoardStore) {
        self.store = store
    }

    public var body: some View {
        TabView {
            Tab("平台", systemImage: "desktopcomputer") {
                PlatformSettingsTab(store: store)
            }

            Tab("语言", systemImage: "chevron.left.forwardslash.chevron.right") {
                LanguageSettingsTab(store: store)
            }
        }
    }
}

// MARK: - Platform

struct PlatformSettingsTab: View {
    @ObservedObject var store: VibeBoardStore
    @State private var newPlatform = PlatformDraft()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach($store.platforms) { $platform in
                    PlatformCard(platform: $platform, store: store)
                }
                AddPlatformCard(draft: $newPlatform, store: store)
            }
            .padding(16)
        }
    }
}

struct PlatformCard: View {
    @Binding var platform: Platform
    @ObservedObject var store: VibeBoardStore
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: platform.icon)
                    .font(.title3)
                    .foregroundStyle(platform.isEnabled ? Color.accentColor : .secondary)
                    .frame(width: 24)

                Text(platform.displayName)
                    .font(.headline)

                Spacer()

                Toggle("", isOn: $platform.isEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { expanded.toggle() }
                } label: {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
            }
            .padding(12)

            if expanded {
                Divider().padding(.horizontal, 12)

                VStack(alignment: .leading, spacing: 10) {
                    FieldRow(label: "图标") {
                        IconPicker(selection: $platform.icon)
                    }
                    FieldRow(label: "名称") {
                        TextField("", text: $platform.displayName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 160)
                    }
                    FieldRow(label: "仓库名") {
                        TextField("", text: $platform.defaultRepoName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 160)
                    }
                }
                .padding(12)

                if !platform.isBuiltIn {
                    HStack {
                        Spacer()
                        Button("删除此平台", role: .destructive) {
                            store.removePlatform(id: platform.id)
                        }
                        .controlSize(.small)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
                }
            }
        }
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator, lineWidth: 0.5))
    }
}

struct AddPlatformCard: View {
    @Binding var draft: PlatformDraft
    @ObservedObject var store: VibeBoardStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("添加自定义平台")
                .font(.headline)

            FieldRow(label: "图标") {
                IconPicker(selection: $draft.icon)
            }
            FieldRow(label: "名称") {
                TextField("", text: $draft.name)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 160)
            }
            FieldRow(label: "仓库名") {
                TextField("", text: $draft.repoName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 160)
            }

            HStack {
                Spacer()
                Button("添加") {
                    let p = Platform(
                        id: draft.name.trimmingCharacters(in: .whitespaces),
                        displayName: draft.name.trimmingCharacters(in: .whitespaces),
                        icon: draft.icon.trimmingCharacters(in: .whitespaces).ifEmpty("desktopcomputer") ?? "desktopcomputer",
                        defaultRepoName: draft.repoName.trimmingCharacters(in: .whitespaces).ifEmpty(nil)
                    )
                    store.addPlatform(p)
                    draft = PlatformDraft()
                }
                .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator, lineWidth: 0.5))
    }
}

struct PlatformDraft {
    var name: String = ""
    var icon: String = "desktopcomputer"
    var repoName: String = ""
}

// MARK: - Field Row

struct FieldRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .center) {
            Text(label)
                .frame(width: 56, alignment: .trailing)
                .foregroundStyle(.secondary)
                .font(.subheadline)
            content
        }
    }
}

// MARK: - Icon Picker

struct IconPicker: View {
    @Binding var selection: String
    @State private var customIcon: String = ""

    private let presets = [
        "desktopcomputer", "macbook", "pc", "server.rack",
        "iphone", "ipad", "smartphone", "appletv",
        "globe", "network", "arcade.stick", "externaldrive",
    ]

    var body: some View {
        HStack(spacing: 4) {
            Menu {
                ForEach(presets, id: \.self) { icon in
                    Button { selection = icon; customIcon = icon } label: {
                        Label(icon, systemImage: icon)
                    }
                }
                Divider()
                Button("自定义...") { customIcon = selection }
            } label: {
                Image(systemName: selection.isEmpty ? "desktopcomputer" : selection)
                    .frame(width: 24, height: 24)
                    .background(.background.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .fixedSize()

            TextField("SF Symbol", text: $customIcon)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
                .onSubmit { selection = customIcon }
                .onChange(of: customIcon) { _, newValue in
                    if !newValue.isEmpty { selection = newValue }
                }
        }
    }
}

// MARK: - Language

struct LanguageSettingsTab: View {
    @ObservedObject var store: VibeBoardStore
    @State private var newDisplayName: String = ""
    @State private var newIcon: String = "chevron.left.forwardslash.chevron.right"

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach($store.languages) { $language in
                    LanguageCard(language: $language, store: store)
                }
                AddLanguageCard(draftName: $newDisplayName, draftIcon: $newIcon, store: store)
            }
            .padding(16)
        }
    }
}

struct LanguageCard: View {
    @Binding var language: Language
    @ObservedObject var store: VibeBoardStore
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: language.icon)
                    .font(.title3)
                    .foregroundStyle(language.isEnabled ? Color.accentColor : .secondary)
                    .frame(width: 24)

                Text(language.displayName)
                    .font(.headline)

                Spacer()

                Toggle("", isOn: $language.isEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { expanded.toggle() }
                } label: {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
            }
            .padding(12)

            if expanded {
                Divider().padding(.horizontal, 12)

                VStack(alignment: .leading, spacing: 10) {
                    FieldRow(label: "图标") {
                        IconPicker(selection: $language.icon)
                    }
                    FieldRow(label: "显示名") {
                        TextField("", text: $language.displayName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 160)
                    }
                }
                .padding(12)

                if !language.isBuiltIn {
                    HStack {
                        Spacer()
                        Button("删除此语言", role: .destructive) {
                            store.removeLanguage(id: language.id)
                        }
                        .controlSize(.small)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
                }
            }
        }
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator, lineWidth: 0.5))
    }
}

struct AddLanguageCard: View {
    @Binding var draftName: String
    @Binding var draftIcon: String
    @ObservedObject var store: VibeBoardStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("添加自定义语言")
                .font(.headline)

            FieldRow(label: "图标") {
                IconPicker(selection: $draftIcon)
            }
            FieldRow(label: "显示名") {
                TextField("", text: $draftName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 160)
            }

            HStack {
                Spacer()
                Button("添加") {
                    let l = Language(
                        id: draftName.trimmingCharacters(in: .whitespaces),
                        displayName: draftName.trimmingCharacters(in: .whitespaces).ifEmpty(nil),
                        icon: draftIcon.trimmingCharacters(in: .whitespaces).ifEmpty("chevron.left.forwardslash.chevron.right") ?? "chevron.left.forwardslash.chevron.right"
                    )
                    store.addLanguage(l)
                    draftName = ""
                    draftIcon = "chevron.left.forwardslash.chevron.right"
                }
                .disabled(draftName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator, lineWidth: 0.5))
    }
}

private extension String {
    func ifEmpty(_ fallback: String?) -> String? {
        isEmpty ? fallback : self
    }
}
