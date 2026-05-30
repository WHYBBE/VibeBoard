import SwiftUI
import Combine

@MainActor
public final class VibeBoardStore: ObservableObject {
    @Published public var projects: [VibeProject] = []
    @Published public var selectedProjectId: UUID?
    @Published public var platforms: [Platform]
    @Published public var languages: [Language]

    public init() {
        self.platforms = Platform.builtInAll
        self.languages = Language.builtInAll
    }

    public var selectedProject: VibeProject? {
        guard let id = selectedProjectId else { return nil }
        return projects.first { $0.id == id }
    }

    public var enabledPlatforms: [Platform] {
        platforms.filter(\.isEnabled)
    }

    public var enabledLanguages: [Language] {
        languages.filter(\.isEnabled)
    }

    // MARK: - Project CRUD

    public func addProject(_ project: VibeProject) {
        projects.append(project)
        selectedProjectId = project.id
    }

    public func deleteProject(_ id: UUID) {
        projects.removeAll { $0.id == id }
        if selectedProjectId == id {
            selectedProjectId = projects.first?.id
        }
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
}
