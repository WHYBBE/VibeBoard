import Foundation

public struct PlatformStatus: Identifiable, Equatable, Codable {
    public var id: String { platformId }

    public var platformId: String
    public var isSupported: Bool
    public var repoName: String
    public var progress: Double
    public var languages: [Language]
    public var llmTags: [LLMTag]

    public init(
        platformId: String,
        isSupported: Bool = false,
        repoName: String,
        progress: Double = 0,
        languages: [Language] = [],
        llmTags: [LLMTag] = []
    ) {
        self.platformId = platformId
        self.isSupported = isSupported
        self.repoName = repoName
        self.progress = progress
        self.languages = languages
        self.llmTags = llmTags
    }

    public init(platform: Platform, isSupported: Bool = false, progress: Double = 0, languages: [Language] = [], llmTags: [LLMTag] = []) {
        self.platformId = platform.id
        self.isSupported = isSupported
        self.repoName = "app-\(platform.id.lowercased())"
        self.progress = progress
        self.languages = languages
        self.llmTags = llmTags
    }
}
