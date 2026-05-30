import Foundation

public struct PlatformStatus: Identifiable, Codable, Equatable {
    public var id: String { platformId }

    public var platformId: String
    public var isSupported: Bool
    public var repoName: String
    public var progress: Double
    public var languages: [Language]

    public init(
        platformId: String,
        isSupported: Bool = false,
        repoName: String,
        progress: Double = 0,
        languages: [Language] = []
    ) {
        self.platformId = platformId
        self.isSupported = isSupported
        self.repoName = repoName
        self.progress = progress
        self.languages = languages
    }

    public init(platform: Platform, isSupported: Bool = false, progress: Double = 0, languages: [Language] = []) {
        self.platformId = platform.id
        self.isSupported = isSupported
        self.repoName = platform.defaultRepoName
        self.progress = progress
        self.languages = languages
    }
}
