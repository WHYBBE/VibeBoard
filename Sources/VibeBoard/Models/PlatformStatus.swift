import Foundation

public struct PlatformStatus: Identifiable, Equatable {
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
        self.repoName = platform.defaultRepoName
        self.progress = progress
        self.languages = languages
        self.llmTags = llmTags
    }
}

extension PlatformStatus: Codable {
    private enum CodingKeys: String, CodingKey {
        case platformId, isSupported, repoName, progress, languages, llmTags
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        platformId = try c.decode(String.self, forKey: .platformId)
        isSupported = try c.decode(Bool.self, forKey: .isSupported)
        repoName = try c.decode(String.self, forKey: .repoName)
        progress = try c.decode(Double.self, forKey: .progress)
        languages = (try? c.decode([Language].self, forKey: .languages)) ?? []
        llmTags = (try? c.decode([LLMTag].self, forKey: .llmTags)) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(platformId, forKey: .platformId)
        try c.encode(isSupported, forKey: .isSupported)
        try c.encode(repoName, forKey: .repoName)
        try c.encode(progress, forKey: .progress)
        try c.encode(languages, forKey: .languages)
        try c.encode(llmTags, forKey: .llmTags)
    }
}
