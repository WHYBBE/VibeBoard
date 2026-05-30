import SwiftUI
import Combine

@MainActor
public final class VibeBoardStore: ObservableObject {
    @Published public var projects: [VibeProject] = []
    @Published public var selectedProjectId: UUID?
    @Published public var platforms: [Platform]
    @Published public var languages: [Language]
    @Published public var appLanguage: AppLanguage
    @Published public var appTheme: AppTheme

    private let saveURL: URL
    private var saveCancellable: AnyCancellable?

    public init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("VibeBoard", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.saveURL = dir.appendingPathComponent("store.json")

        if let data = try? Data(contentsOf: saveURL),
           let decoded = try? JSONDecoder().decode(StoreSnapshot.self, from: data) {
            self.projects = decoded.projects
            self.selectedProjectId = decoded.selectedProjectId
            self.platforms = decoded.platforms
            self.languages = decoded.languages
            self.appLanguage = decoded.appLanguage ?? .zh
            self.appTheme = decoded.appTheme ?? .system
        } else {
            self.platforms = Platform.builtInAll
            self.languages = Language.builtInAll
            self.appLanguage = .zh
            self.appTheme = .system
        }

        S.lang = appLanguage

        saveCancellable = objectWillChange
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.saveNow()
            }

        langCancellable = $appLanguage
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] lang in
                S.lang = lang
                self?.objectWillChange.send()
            }
    }

    private var langCancellable: AnyCancellable?

    private func saveNow() {
        let snapshot = StoreSnapshot(
            projects: projects,
            selectedProjectId: selectedProjectId,
            platforms: platforms,
            languages: languages,
            appLanguage: appLanguage,
            appTheme: appTheme
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: saveURL, options: .atomic)
    }

    public var selectedProject: VibeProject? {
        guard let id = selectedProjectId else { return nil }
        return projects.first { $0.id == id }
    }

    public var enabledPlatforms: [Platform] { platforms.filter(\.isEnabled) }
    public var enabledLanguages: [Language] { languages.filter(\.isEnabled) }

    // MARK: - Project CRUD

    public func addProject(_ project: VibeProject) {
        projects.append(project)
        selectedProjectId = project.id
    }

    public func deleteProject(_ id: UUID) {
        projects.removeAll { $0.id == id }
        if selectedProjectId == id { selectedProjectId = projects.first?.id }
    }

    public func updateProject(_ project: VibeProject) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        }
    }

    // MARK: - Platform Status

    public func setPlatformSupported(_ platformId: String, projectId: UUID, supported: Bool) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        if let pIndex = projects[index].platformStatuses.firstIndex(where: { $0.platformId == platformId }) {
            projects[index].platformStatuses[pIndex].isSupported = supported
        }
    }

    public func setPlatformProgress(_ platformId: String, projectId: UUID, progress: Double) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        if let pIndex = projects[index].platformStatuses.firstIndex(where: { $0.platformId == platformId }) {
            projects[index].platformStatuses[pIndex].progress = progress
        }
    }

    public func setPlatformRepoName(_ platformId: String, projectId: UUID, repoName: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        if let pIndex = projects[index].platformStatuses.firstIndex(where: { $0.platformId == platformId }) {
            projects[index].platformStatuses[pIndex].repoName = repoName
        }
    }

    public func addPlatformStatusToProject(_ platform: Platform, projectId: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        if projects[index].platformStatuses.contains(where: { $0.platformId == platform.id }) { return }
        projects[index].platformStatuses.append(PlatformStatus(platform: platform))
    }

    public func removePlatformStatusFromProject(_ platformId: String, projectId: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].platformStatuses.removeAll { $0.platformId == platformId }
    }

    // MARK: - Project Languages

    public func setProjectLanguages(_ languages: [Language], projectId: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].languages = languages
    }

    public func toggleLanguageInProject(_ language: Language, projectId: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        if let lIndex = projects[index].languages.firstIndex(of: language) {
            projects[index].languages.remove(at: lIndex)
        } else {
            projects[index].languages.append(language)
        }
    }

    // MARK: - Project Keywords

    public func setProjectKeywords(_ keywords: [String], projectId: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].keywords = keywords
    }

    public func addKeyword(_ keyword: String, projectId: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        if !projects[index].keywords.contains(keyword) {
            projects[index].keywords.append(keyword)
        }
    }

    public func removeKeyword(_ keyword: String, projectId: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].keywords.removeAll { $0 == keyword }
    }

    // MARK: - Settings: Platform Management

    public func addPlatform(_ platform: Platform) {
        if !platforms.contains(where: { $0.id == platform.id }) {
            platforms.append(platform)
        }
    }

    public func removePlatform(id: String) {
        platforms.removeAll { $0.id == id }
        for index in projects.indices {
            projects[index].platformStatuses.removeAll { $0.platformId == id }
        }
    }

    public func setPlatformEnabled(_ id: String, enabled: Bool) {
        if let index = platforms.firstIndex(where: { $0.id == id }) {
            platforms[index].isEnabled = enabled
        }
    }

    public func updatePlatform(_ platform: Platform) {
        if let index = platforms.firstIndex(where: { $0.id == platform.id }) {
            platforms[index] = platform
        }
    }

    // MARK: - Settings: Language Management

    public func addLanguage(_ language: Language) {
        if !languages.contains(where: { $0.id == language.id }) {
            languages.append(language)
        }
    }

    public func removeLanguage(id: String) {
        languages.removeAll { $0.id == id }
        for index in projects.indices {
            projects[index].languages.removeAll { $0.id == id }
        }
    }

    public func setLanguageEnabled(_ id: String, enabled: Bool) {
        if let index = languages.firstIndex(where: { $0.id == id }) {
            languages[index].isEnabled = enabled
        }
    }

    public func updateLanguage(_ language: Language) {
        if let index = languages.firstIndex(where: { $0.id == language.id }) {
            languages[index] = language
        }
    }

    // MARK: - Import / Export

    public func exportData() -> Data? {
        let snapshot = StoreSnapshot(
            projects: projects,
            selectedProjectId: selectedProjectId,
            platforms: platforms,
            languages: languages,
            appLanguage: appLanguage,
            appTheme: appTheme
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(snapshot)
    }

    public func importData(_ data: Data) -> Bool {
        guard let decoded = try? JSONDecoder().decode(StoreSnapshot.self, from: data) else { return false }
        projects = decoded.projects
        selectedProjectId = decoded.selectedProjectId
        platforms = decoded.platforms
        languages = decoded.languages
        appLanguage = decoded.appLanguage ?? .zh
        appTheme = decoded.appTheme ?? .system
        S.lang = appLanguage
        return true
    }
}

private struct StoreSnapshot: Codable {
    var projects: [VibeProject]
    var selectedProjectId: UUID?
    var platforms: [Platform]
    var languages: [Language]
    var appLanguage: AppLanguage?
    var appTheme: AppTheme?
}
