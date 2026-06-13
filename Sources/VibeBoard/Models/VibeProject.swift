import Foundation

public struct VibeProject: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var keywords: [String]
    public var subProjectIds: [UUID]
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        keywords: [String] = [],
        subProjectIds: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.keywords = keywords
        self.subProjectIds = subProjectIds
        self.createdAt = createdAt
    }
}
