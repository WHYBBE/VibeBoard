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

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        keywords = try c.decodeIfPresent([String].self, forKey: .keywords) ?? []
        subProjectIds = try c.decodeIfPresent([UUID].self, forKey: .subProjectIds) ?? []
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}
