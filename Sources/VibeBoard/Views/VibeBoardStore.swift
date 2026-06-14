import SwiftUI
import Combine

@MainActor
public final class VibeBoardStore: ObservableObject {
    @Published public var projects: [VibeProject] = []
    @Published public var selectedProjectId: UUID?
    @Published public var selectedSubProjectId: UUID?
    @Published public var platforms: [Platform] = Platform.builtInAll
    @Published public var languages: [Language] = Language.builtInAll
    @Published public var llmTags: [LLMTag] = LLMTag.builtInAll
    @Published public var appLanguage: AppLanguage = .zh
    @Published public var appTheme: AppTheme = .system
    @Published public var subProjects: [SubProject] = []

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
            self.llmTags = decoded.llmTags
            self.subProjects = decoded.subProjects
            self.appLanguage = decoded.appLanguage
            self.appTheme = decoded.appTheme
        } else {
            self.platforms = Platform.builtInAll
            self.languages = Language.builtInAll
            self.llmTags = LLMTag.builtInAll
            self.appLanguage = .zh
            self.appTheme = .system
        }

        S.lang = appLanguage
        UserDefaults.standard.set(appTheme.rawValue, forKey: "VB_appTheme")
        UserDefaults.standard.set(appLanguage.rawValue, forKey: "VB_appLanguage")

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
            llmTags: llmTags,
            subProjects: subProjects,
            appLanguage: appLanguage,
            appTheme: appTheme
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: saveURL, options: .atomic)
        UserDefaults.standard.set(appLanguage.rawValue, forKey: "VB_appLanguage")
        UserDefaults.standard.set(appTheme.rawValue, forKey: "VB_appTheme")
    }

    public var selectedProject: VibeProject? {
        guard let id = selectedProjectId else { return nil }
        return projects.first { $0.id == id }
    }

    public var enabledPlatforms: [Platform] { platforms.filter(\.isEnabled) }
    public var validLanguageIds: Set<String> { Set(languages.map(\.id)) }
    public var validLLMTagIds: Set<String> { Set(llmTags.map(\.id)) }

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

    // MARK: - SubProject CRUD

    public func addSubProject(_ sub: SubProject) {
        subProjects.append(sub)
    }

    public func deleteSubProject(_ id: UUID) {
        subProjects.removeAll { $0.id == id }
        for i in projects.indices {
            projects[i].subProjectIds.removeAll { $0 == id }
        }
    }

    public func updateSubProject(_ sub: SubProject) {
        if let index = subProjects.firstIndex(where: { $0.id == sub.id }) {
            subProjects[index] = sub
        }
    }

    public func toggleLanguageInSubProject(_ language: Language, subProjectId: UUID) {
        guard let index = subProjects.firstIndex(where: { $0.id == subProjectId }) else { return }
        if let lIndex = subProjects[index].languages.firstIndex(of: language) {
            subProjects[index].languages.remove(at: lIndex)
        } else {
            subProjects[index].languages.append(language)
        }
    }

    public func toggleLLMTagInSubProject(_ tag: LLMTag, subProjectId: UUID) {
        guard let index = subProjects.firstIndex(where: { $0.id == subProjectId }) else { return }
        if let tIndex = subProjects[index].llmTags.firstIndex(of: tag) {
            subProjects[index].llmTags.remove(at: tIndex)
        } else {
            subProjects[index].llmTags.append(tag)
        }
    }

    public func togglePlatformInSubProject(_ platformId: String, subProjectId: UUID) {
        guard let index = subProjects.firstIndex(where: { $0.id == subProjectId }) else { return }
        if let pIndex = subProjects[index].platformIds.firstIndex(of: platformId) {
            subProjects[index].platformIds.remove(at: pIndex)
        } else {
            subProjects[index].platformIds.append(platformId)
        }
    }

    public func bindSubProject(_ subProjectId: UUID, toProject projectId: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        if !projects[index].subProjectIds.contains(subProjectId) {
            projects[index].subProjectIds.append(subProjectId)
        }
    }

    public func unbindSubProject(_ subProjectId: UUID, fromProject projectId: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].subProjectIds.removeAll { $0 == subProjectId }
    }

    public func subProjects(forProject projectId: UUID) -> [SubProject] {
        guard let project = projects.first(where: { $0.id == projectId }) else { return [] }
        return subProjects.filter { project.subProjectIds.contains($0.id) }
    }

    public var unboundSubProjects: [SubProject] {
        let boundIds = Set(projects.flatMap(\.subProjectIds))
        return subProjects.filter { !boundIds.contains($0.id) }
    }

    public func addSubProjectToProject(_ sub: SubProject, projectId: UUID) {
        addSubProject(sub)
        bindSubProject(sub.id, toProject: projectId)
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
        for i in subProjects.indices {
            subProjects[i].platformIds.removeAll { $0 == id }
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
        for i in subProjects.indices {
            subProjects[i].languages.removeAll { $0.id == id }
        }
    }

    public func updateLanguage(_ language: Language) {
        if let index = languages.firstIndex(where: { $0.id == language.id }) {
            languages[index] = language
        }
    }

    // MARK: - Settings: LLM Tag Management

    public func addLLMTag(_ tag: LLMTag) {
        if !llmTags.contains(where: { $0.id == tag.id }) {
            llmTags.append(tag)
        }
    }

    public func removeLLMTag(id: String) {
        llmTags.removeAll { $0.id == id }
        for i in subProjects.indices {
            subProjects[i].llmTags.removeAll { $0.id == id }
        }
    }

    public func updateLLMTag(_ tag: LLMTag) {
        if let index = llmTags.firstIndex(where: { $0.id == tag.id }) {
            llmTags[index] = tag
        }
    }

    // MARK: - Import / Export

    public func exportData() -> Data? {
        let snapshot = StoreSnapshot(
            projects: projects,
            selectedProjectId: selectedProjectId,
            platforms: platforms,
            languages: languages,
            llmTags: llmTags,
            subProjects: subProjects,
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
        platforms = decoded.platforms.isEmpty ? Platform.builtInAll : decoded.platforms
        languages = decoded.languages
        llmTags = decoded.llmTags
        subProjects = decoded.subProjects
        appLanguage = decoded.appLanguage
        appTheme = decoded.appTheme
        S.lang = appLanguage
        return true
    }

    public func clearAll() {
        projects = []
        selectedProjectId = nil
        platforms = Platform.builtInAll
        languages = Language.builtInAll
        llmTags = LLMTag.builtInAll
        subProjects = []
    }
}

private struct StoreSnapshot: Codable {
    var projects: [VibeProject]
    var selectedProjectId: UUID?
    var platforms: [Platform]
    var languages: [Language]
    var llmTags: [LLMTag]
    var subProjects: [SubProject]
    var appLanguage: AppLanguage
    var appTheme: AppTheme

    init(projects: [VibeProject], selectedProjectId: UUID?, platforms: [Platform], languages: [Language], llmTags: [LLMTag], subProjects: [SubProject], appLanguage: AppLanguage, appTheme: AppTheme) {
        self.projects = projects
        self.selectedProjectId = selectedProjectId
        self.platforms = platforms
        self.languages = languages
        self.llmTags = llmTags
        self.subProjects = subProjects
        self.appLanguage = appLanguage
        self.appTheme = appTheme
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        projects = try c.decodeIfPresent([VibeProject].self, forKey: .projects) ?? []
        selectedProjectId = try c.decodeIfPresent(UUID.self, forKey: .selectedProjectId)
        platforms = try c.decodeIfPresent([Platform].self, forKey: .platforms) ?? []
        languages = try c.decodeIfPresent([Language].self, forKey: .languages) ?? []
        llmTags = try c.decodeIfPresent([LLMTag].self, forKey: .llmTags) ?? []
        subProjects = try c.decodeIfPresent([SubProject].self, forKey: .subProjects) ?? []
        appLanguage = (try? c.decodeIfPresent(AppLanguage.self, forKey: .appLanguage)) ?? .zh
        appTheme = (try? c.decodeIfPresent(AppTheme.self, forKey: .appTheme)) ?? .system
    }
}
