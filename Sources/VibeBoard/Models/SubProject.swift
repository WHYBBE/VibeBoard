import Foundation

public struct SubProject: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var platformIds: [String]
    public var isSupported: Bool
    public var repoURL: String
    public var icon: String
    public var colorHex: String
    public var languages: [Language]
    public var llmTags: [LLMTag]
    public var progress: Double
    public var createdAt: Date

    public var repoName: String { name }

    public var isShared: Bool { platformIds.count > 1 }

    public var displayIcon: String {
        icon.isEmpty ? (isShared ? "link.circle.fill" : "cube.box") : icon
    }

    public var displayColor: String {
        colorHex.isEmpty ? (isShared ? "007AFF" : "FF9500") : colorHex
    }

    public init(
        id: UUID = UUID(),
        name: String,
        platformIds: [String] = [],
        isSupported: Bool = true,
        repoURL: String = "",
        icon: String = "",
        colorHex: String = "",
        languages: [Language] = [],
        llmTags: [LLMTag] = [],
        progress: Double = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.platformIds = platformIds
        self.isSupported = isSupported
        self.repoURL = repoURL
        self.icon = icon
        self.colorHex = colorHex
        self.languages = languages
        self.llmTags = llmTags
        self.progress = progress
        self.createdAt = createdAt
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        platformIds = try c.decodeIfPresent([String].self, forKey: .platformIds) ?? []
        isSupported = try c.decodeIfPresent(Bool.self, forKey: .isSupported) ?? true
        repoURL = try c.decodeIfPresent(String.self, forKey: .repoURL) ?? ""
        icon = try c.decodeIfPresent(String.self, forKey: .icon) ?? ""
        colorHex = try c.decodeIfPresent(String.self, forKey: .colorHex) ?? ""
        languages = try c.decodeIfPresent([Language].self, forKey: .languages) ?? []
        llmTags = try c.decodeIfPresent([LLMTag].self, forKey: .llmTags) ?? []
        progress = try c.decodeIfPresent(Double.self, forKey: .progress) ?? 0
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}
