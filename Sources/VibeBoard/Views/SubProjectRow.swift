import SwiftUI

struct SubProjectRow: View {
    @ObservedObject var store: VibeBoardStore
    @Binding var subProject: SubProject
    var projectId: UUID?
    var standalone: Bool = false
    @State private var showDeleteConfirm = false

    var body: some View {
        if standalone {
            standaloneLayout
        } else {
            cardLayout
        }
    }

    private var cardLayout: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                IconPickerField(icon: $subProject.icon, colorHex: $subProject.colorHex, defaultIcon: subProject.isShared ? "link.circle.fill" : "cube.box", defaultColorHex: subProject.isShared ? "007AFF" : "FF9500")
                    .font(.title3)
                    .frame(width: 24)

                TextField(S.detail.subProjectName, text: $subProject.name)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)

                Spacer()

                Toggle(S.detail.implemented, isOn: $subProject.isSupported)
                    .toggleStyle(.switch)

                if let projectId = projectId {
                    Button(S.detail.unbind) {
                        store.unbindSubProject(subProject.id, fromProject: projectId)
                    }
                    .controlSize(.small)
                }

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .alert(S.detail.deleteSubProjectConfirmTitle, isPresented: $showDeleteConfirm) {
                    Button(S.detail.deleteSubProjectConfirmTitle, role: .destructive) {
                        store.deleteSubProject(subProject.id)
                    }
                    Button(S.sidebar.cancel, role: .cancel) {}
                } message: {
                    Text(S.detail.deleteSubProjectConfirmMessage)
                }
            }

            HStack(spacing: 12) {
                Label(S.detail.repoURL, systemImage: "link")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
                TextField(S.detail.repoURL, text: $subProject.repoURL)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
            }

            HStack(spacing: 12) {
                Label(S.detail.progress, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
                Slider(value: $subProject.progress, in: 0...1)
                    .frame(maxWidth: 200)
                Text("\(Int(subProject.progress * 100))%")
                    .font(.caption.monospacedDigit())
                    .frame(width: 40)
            }

            if !store.platforms.isEmpty {
                HStack(alignment: .top, spacing: 12) {
                    Label(S.detail.subProjectPlatforms, systemImage: "desktopcomputer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .trailing)
                        .padding(.top, 2)

                    FlowLayout(spacing: 6) {
                        ForEach(store.platforms) { platform in
                            PlatformToggleTag(
                                platform: platform,
                                isSelected: subProject.platformIds.contains(platform.id),
                                onToggle: { store.togglePlatformInSubProject(platform.id, subProjectId: subProject.id) }
                            )
                        }
                    }
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
                                isSelected: subProject.languages.contains(language),
                                onToggle: { store.toggleLanguageInSubProject(language, subProjectId: subProject.id) }
                            )
                        }
                    }
                }
            }

            if !store.llmTags.isEmpty {
                HStack(alignment: .top, spacing: 12) {
                    Label(S.detail.llmTags, systemImage: "cpu")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .trailing)
                        .padding(.top, 2)

                    FlowLayout(spacing: 6) {
                        ForEach(store.llmTags) { tag in
                            LLMTagToggleTag(
                                tag: tag,
                                isSelected: subProject.llmTags.contains(tag),
                                onToggle: { store.toggleLLMTagInSubProject(tag, subProjectId: subProject.id) }
                            )
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(Color(hex: subProject.displayColor).opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(
            Color(hex: subProject.displayColor).opacity(0.3),
            lineWidth: 0.5
        ))
    }

    private var standaloneLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                standaloneHeader
                standaloneFieldsCard
                standalonePlatformsCard
                standaloneLanguagesCard
                standaloneLLMTagsCard
            }
            .padding(24)
        }
    }

    private var standaloneHeader: some View {
        HStack(alignment: .bottom, spacing: 16) {
            IconPickerField(icon: $subProject.icon, colorHex: $subProject.colorHex, defaultIcon: subProject.isShared ? "link.circle.fill" : "cube.box", defaultColorHex: subProject.isShared ? "007AFF" : "FF9500")
                .font(.title)

            TextField(S.detail.subProjectName, text: $subProject.name)
                .font(.title.bold())
                .textFieldStyle(.roundedBorder)

            Spacer()

            Toggle(S.detail.implemented, isOn: $subProject.isSupported)
                .toggleStyle(.switch)

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
            }
            .alert(S.detail.deleteSubProjectConfirmTitle, isPresented: $showDeleteConfirm) {
                Button(S.detail.deleteSubProjectConfirmTitle, role: .destructive) {
                    store.deleteSubProject(subProject.id)
                }
                Button(S.sidebar.cancel, role: .cancel) {}
            } message: {
                Text(S.detail.deleteSubProjectConfirmMessage)
            }
        }
    }

    private var standaloneFieldsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Label(S.detail.repoURL, systemImage: "link")
                    .font(.headline)
                    .frame(width: 80, alignment: .trailing)
                TextField(S.detail.repoURL, text: $subProject.repoURL)
                    .textFieldStyle(.roundedBorder)
            }

            HStack(spacing: 12) {
                Label(S.detail.progress, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                    .frame(width: 80, alignment: .trailing)
                Slider(value: $subProject.progress, in: 0...1)
                Text("\(Int(subProject.progress * 100))%")
                    .font(.body.monospacedDigit())
                    .frame(width: 50)
            }
        }
        .padding(16)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var standalonePlatformsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(S.detail.subProjectPlatforms, systemImage: "desktopcomputer")
                .font(.headline)

            if store.platforms.isEmpty {
                Text(S.detail.addSubProjectHint)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(store.platforms) { platform in
                        PlatformToggleTag(
                            platform: platform,
                            isSelected: subProject.platformIds.contains(platform.id),
                            onToggle: { store.togglePlatformInSubProject(platform.id, subProjectId: subProject.id) }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var standaloneLanguagesCard: some View {
        if !store.languages.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Label(S.detail.languages, systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(.headline)

                FlowLayout(spacing: 8) {
                    ForEach(store.languages) { language in
                        LanguageToggleTag(
                            language: language,
                            isSelected: subProject.languages.contains(language),
                            onToggle: { store.toggleLanguageInSubProject(language, subProjectId: subProject.id) }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private var standaloneLLMTagsCard: some View {
        if !store.llmTags.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Label(S.detail.llmTags, systemImage: "cpu")
                    .font(.headline)

                FlowLayout(spacing: 8) {
                    ForEach(store.llmTags) { tag in
                        LLMTagToggleTag(
                            tag: tag,
                            isSelected: subProject.llmTags.contains(tag),
                            onToggle: { store.toggleLLMTagInSubProject(tag, subProjectId: subProject.id) }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct PlatformToggleTag: View {
    let platform: Platform
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Image(systemName: platform.icon)
                    .font(.caption2)
                Text(platform.displayName)
                    .font(.subheadline)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .primary : .secondary)
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

struct LLMTagToggleTag: View {
    let tag: LLMTag
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Text(tag.displayName)
                    .font(.subheadline)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isSelected ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .primary : .secondary)
    }
}

struct IconPickerField: View {
    @Binding var icon: String
    @Binding var colorHex: String
    let defaultIcon: String
    let defaultColorHex: String
    @State private var showPicker = false
    @State private var frozenColorHex: String = ""
    @State private var customIconInput: String = ""
    @State private var pickerColor: Color = .orange

    private var effectiveIcon: String { icon.isEmpty ? defaultIcon : icon }
    private var effectiveColor: Color { Color(hex: (showPicker ? frozenColorHex : colorHex).isEmpty ? defaultColorHex : (showPicker ? frozenColorHex : colorHex)) }

    private static let presetColors: [String] = [
        "FF9500", "007AFF", "34C759", "AF52DE", "FF3B30",
        "5AC8FA", "5856D6", "FF2D55", "FFCC00", "8E8E93",
    ]

    var body: some View {
        Button {
            frozenColorHex = colorHex
            pickerColor = Color(hex: colorHex.isEmpty ? defaultColorHex : colorHex)
            showPicker = true
        } label: {
            Image(systemName: effectiveIcon)
                .foregroundStyle(effectiveColor)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPicker) {
            iconPickerContent
        }
    }

    private func hexFromColor(_ color: Color) -> String {
        #if canImport(AppKit)
        let nsColor = NSColor(color)
        guard let rgb = nsColor.usingColorSpace(.sRGB) else { return colorHex.isEmpty ? defaultColorHex : colorHex }
        return String(format: "%02X%02X%02X", Int(rgb.redComponent * 255), Int(rgb.greenComponent * 255), Int(rgb.blueComponent * 255))
        #else
        let uiColor = UIColor(color)
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        #endif
    }

    private var iconPickerContent: some View {
        VStack(spacing: 14) {
            Text(S.detail.changeIcon)
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 6) {
                ForEach(SubProjectIconPresets.all, id: \.self) { name in
                    Button {
                        icon = name == defaultIcon ? "" : name
                    } label: {
                        Image(systemName: name)
                            .font(.title3)
                            .frame(width: 36, height: 36)
                            .background(icon == name || (icon.isEmpty && name == defaultIcon) ? Color.gray.opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                }
            }

            HStack {
                TextField(S.detail.customIcon, text: $customIconInput)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)

                Button("OK") {
                    let trimmed = customIconInput.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty { icon = trimmed }
                    customIconInput = ""
                }
                .disabled(customIconInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Divider()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 6), spacing: 6) {
                ForEach(Self.presetColors, id: \.self) { hex in
                    Button {
                        colorHex = hex == defaultColorHex ? "" : hex
                    } label: {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 28, height: 28)
                            .overlay(Circle().strokeBorder(.primary, lineWidth: colorHex == hex ? 2 : 0))
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    colorHex = String(format: "%02X%02X%02X", Int.random(in: 50...255), Int.random(in: 50...255), Int.random(in: 50...255))
                } label: {
                    Image(systemName: "die.face.5")
                        .font(.callout)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            HStack {
                ColorPicker(selection: $pickerColor) {
                    Text(S.detail.color)
                        .font(.subheadline)
                }
                .onChange(of: pickerColor) { _, newColor in
                    colorHex = hexFromColor(newColor)
                }

                Spacer()

                Text(colorHex.isEmpty ? defaultColorHex : colorHex)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(width: 250)
    }
}

struct SubProjectIconPresets {
    static let all = [
        "cube.box",
        "link.circle.fill",
        "folder.fill",
        "doc.fill",
        "hammer.fill",
        "wrench.and.screwdriver.fill",
        "gearshape.fill",
        "server.rack",
        "network",
        "externaldrive.fill",
        "desktopcomputer",
        "smartphone",
        "globe",
        "pc",
        "terminal.fill",
        "chevron.left.forwardslash.chevron.right",
        "cpu",
        "arrow.triangle.branch",
        "building.2.fill",
        "star.fill",
    ]
}
