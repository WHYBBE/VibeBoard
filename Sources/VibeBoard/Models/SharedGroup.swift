import Foundation

public struct SharedGroup: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var platformIds: [String]
    public var repoName: String
    public var languages: [Language]
    public var progress: Double

    public init(
        id: UUID = UUID(),
        name: String = "",
        platformIds: [String] = [],
        repoName: String = "",
        languages: [Language] = [],
        progress: Double = 0
    ) {
        self.id = id
        self.name = name
        self.platformIds = platformIds
        self.repoName = repoName
        self.languages = languages
        self.progress = progress
    }
}
