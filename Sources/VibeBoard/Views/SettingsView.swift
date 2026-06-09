import SwiftUI

public struct SettingsView: View {
    @ObservedObject var store: VibeBoardStore

    public init(store: VibeBoardStore) {
        self.store = store
    }

    public var body: some View {
        TabView {
            Tab(S.settings.general, systemImage: "gear") {
                GeneralSettingsTab(store: store)
            }

            Tab(S.settings.platform, systemImage: "desktopcomputer") {
                PlatformSettingsTab(store: store)
            }

            Tab(S.settings.language, systemImage: "chevron.left.forwardslash.chevron.right") {
                LanguageSettingsTab(store: store)
            }

            Tab(S.settings.llm, systemImage: "cpu") {
                LLMSettingsTab(store: store)
            }
        }
    }
}

// MARK: - General

struct GeneralSettingsTab: View {
    @ObservedObject var store: VibeBoardStore
    @State private var showExportPanel = false
    @State private var showImportPanel = false
    @State private var showClearConfirm = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false

    var body: some View {
        Form {
            Section(S.settings.appLanguage) {
                Picker(selection: $store.appLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                } label: {
                    Label(S.settings.appLanguage, systemImage: "globe")
                }
                .pickerStyle(.segmented)
            }

            Section(S.settings.theme) {
                Picker(selection: $store.appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.localizedName).tag(theme)
                    }
                } label: {
                    Label(S.settings.theme, systemImage: "circle.lefthalf.filled")
                }
                .pickerStyle(.segmented)
            }

            Section(S.settings.dataManagement) {
                HStack {
                    Label(S.settings.dataManagement, systemImage: "externaldrive")
                    Spacer()
                    Button(S.settings.exportData) { showExportPanel = true }
                    Button(S.settings.importData) { showImportPanel = true }
                    Button(S.settings.clearData, role: .destructive) { showClearConfirm = true }
                }
            }
        }
        .formStyle(.grouped)
        .fileExporter(isPresented: $showExportPanel, document: VibeBoardDocument(data: store.exportData() ?? Data()), contentType: .json, defaultFilename: "VibeBoard-backup") { result in
            switch result {
            case .success:
                alertTitle = S.settings.exportSuccess
                alertMessage = ""
            case .failure:
                alertTitle = S.settings.exportFail
                alertMessage = ""
            }
            showAlert = true
        }
        .fileImporter(isPresented: $showImportPanel, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                if let data = try? Data(contentsOf: url), store.importData(data) {
                    alertTitle = S.settings.importSuccess
                    alertMessage = ""
                } else {
                    alertTitle = S.settings.importFail
                    alertMessage = ""
                }
            case .failure:
                alertTitle = S.settings.importFail
                alertMessage = ""
            }
            showAlert = true
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert(S.settings.clearConfirmTitle, isPresented: $showClearConfirm) {
            Button(S.settings.clearData, role: .destructive) {
                store.clearAll()
                alertTitle = S.settings.clearSuccess
                alertMessage = ""
                showAlert = true
            }
            Button(S.sidebar.cancel, role: .cancel) {}
        } message: {
            Text(S.settings.clearConfirmMessage)
        }
    }
}

extension AppTheme {
    var localizedName: String {
        switch self {
        case .system: return S.settings.themeSystem
        case .light: return S.settings.themeLight
        case .dark: return S.settings.themeDark
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
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: platform.icon)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 24)

                Text(platform.displayName)
                    .font(.headline)

                Spacer()

                Toggle(S.settings.defaultEnabled, isOn: $platform.isEnabled)
                    .toggleStyle(.switch)

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
                    FieldRow(label: S.settings.icon) {
                        IconPicker(selection: $platform.icon)
                    }
                    FieldRow(label: S.settings.name) {
                        TextField("", text: $platform.displayName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 160)
                    }
                }
                .padding(12)

                if !platform.isBuiltIn {
                    HStack {
                        Spacer()
                        Button(S.settings.deletePlatform, role: .destructive) {
                            showDeleteConfirm = true
                        }
                        .controlSize(.small)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
                    .alert(S.settings.deleteCustomPlatformConfirmTitle, isPresented: $showDeleteConfirm) {
                        Button(S.settings.deletePlatform, role: .destructive) {
                            store.removePlatform(id: platform.id)
                        }
                        Button(S.sidebar.cancel, role: .cancel) {}
                    } message: {
                        Text(S.settings.deleteCustomPlatformConfirmMessage)
                    }
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
            Text(S.settings.addCustomPlatform)
                .font(.headline)

            FieldRow(label: S.settings.icon) {
                IconPicker(selection: $draft.icon)
            }
            FieldRow(label: S.settings.name) {
                TextField("", text: $draft.name)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 160)
            }

            HStack {
                Spacer()
                Button(S.detail.add) {
                    let p = Platform(
                        id: draft.name.trimmingCharacters(in: .whitespaces),
                        displayName: draft.name.trimmingCharacters(in: .whitespaces),
                        icon: draft.icon.trimmingCharacters(in: .whitespaces).ifEmpty("desktopcomputer") ?? "desktopcomputer"
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
                Button(S.settings.customize) { customIcon = selection }
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
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: language.icon)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 24)

                Text(language.displayName)
                    .font(.headline)

                Spacer()

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
                    FieldRow(label: S.settings.icon) {
                        IconPicker(selection: $language.icon)
                    }
                    FieldRow(label: S.settings.displayName) {
                        TextField("", text: $language.displayName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 160)
                    }
                }
                .padding(12)

                HStack {
                    Spacer()
                    Button(S.settings.deleteLanguage, role: .destructive) {
                        showDeleteConfirm = true
                    }
                    .controlSize(.small)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
                .alert(S.settings.deleteCustomLanguageConfirmTitle, isPresented: $showDeleteConfirm) {
                    Button(S.settings.deleteLanguage, role: .destructive) {
                        store.removeLanguage(id: language.id)
                    }
                    Button(S.sidebar.cancel, role: .cancel) {}
                } message: {
                    Text(S.settings.deleteCustomLanguageConfirmMessage)
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
            Text(S.settings.addCustomLanguage)
                .font(.headline)

            FieldRow(label: S.settings.icon) {
                IconPicker(selection: $draftIcon)
            }
            FieldRow(label: S.settings.displayName) {
                TextField("", text: $draftName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 160)
            }

            HStack {
                Spacer()
                Button(S.detail.add) {
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

// MARK: - LLM Tag

struct LLMSettingsTab: View {
    @ObservedObject var store: VibeBoardStore
    @State private var newDisplayName: String = ""
    @State private var newIcon: String = "cpu"

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach($store.llmTags) { $tag in
                    LLMTagCard(tag: $tag, store: store)
                }
                AddLLMTagCard(draftName: $newDisplayName, draftIcon: $newIcon, store: store)
            }
            .padding(16)
        }
    }
}

struct LLMTagCard: View {
    @Binding var tag: LLMTag
    @ObservedObject var store: VibeBoardStore
    @State private var expanded = false
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: tag.icon)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 24)

                Text(tag.displayName)
                    .font(.headline)

                Spacer()

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
                    FieldRow(label: S.settings.icon) {
                        IconPicker(selection: $tag.icon)
                    }
                    FieldRow(label: S.settings.displayName) {
                        TextField("", text: $tag.displayName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 160)
                    }
                }
                .padding(12)

                HStack {
                    Spacer()
                    Button(S.settings.deleteLLMTag, role: .destructive) {
                        showDeleteConfirm = true
                    }
                    .controlSize(.small)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
                .alert(S.settings.deleteCustomLLMTagConfirmTitle, isPresented: $showDeleteConfirm) {
                    Button(S.settings.deleteLLMTag, role: .destructive) {
                        store.removeLLMTag(id: tag.id)
                    }
                    Button(S.sidebar.cancel, role: .cancel) {}
                } message: {
                    Text(S.settings.deleteCustomLLMTagConfirmMessage)
                }
            }
        }
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator, lineWidth: 0.5))
    }
}

struct AddLLMTagCard: View {
    @Binding var draftName: String
    @Binding var draftIcon: String
    @ObservedObject var store: VibeBoardStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(S.settings.addCustomLLMTag)
                .font(.headline)

            FieldRow(label: S.settings.icon) {
                IconPicker(selection: $draftIcon)
            }
            FieldRow(label: S.settings.displayName) {
                TextField("", text: $draftName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 160)
            }

            HStack {
                Spacer()
                Button(S.detail.add) {
                    let t = LLMTag(
                        id: draftName.trimmingCharacters(in: .whitespaces),
                        displayName: draftName.trimmingCharacters(in: .whitespaces).ifEmpty(nil),
                        icon: draftIcon.trimmingCharacters(in: .whitespaces).ifEmpty("cpu") ?? "cpu"
                    )
                    store.addLLMTag(t)
                    draftName = ""
                    draftIcon = "cpu"
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
