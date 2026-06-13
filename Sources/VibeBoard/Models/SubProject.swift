import Foundation

public struct SubProject: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var platformIds: [String]
    public var isSupported: Bool
    public var repoName: String
    public var languages: [Language]
    public var llmTags: [LLMTag]
    public var progress: Double
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        platformIds: [String] = [],
        isSupported: Bool = true,
        repoName: String = "",
        languages: [Language] = [],
        llmTags: [LLMTag] = [],
        progress: Double = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.platformIds = platformIds
        self.isSupported = isSupported
        self.repoName = repoName
        self.languages = languages
        self.llmTags = llmTags
        self.progress = progress
        self.createdAt = createdAt
    }
}
