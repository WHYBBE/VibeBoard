import Foundation

public struct VibeProject: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var keywords: [String]
    public var platformStatuses: [PlatformStatus]
    public var subProjectIds: [UUID]
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        keywords: [String] = [],
        platformStatuses: [PlatformStatus] = [],
        subProjectIds: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.keywords = keywords
        self.platformStatuses = platformStatuses
        self.subProjectIds = subProjectIds
        self.createdAt = createdAt
    }

    public func status(forPlatformId id: String) -> PlatformStatus? {
        platformStatuses.first { $0.platformId == id }
    }

    public func isSupported(onPlatformId id: String) -> Bool {
        status(forPlatformId: id)?.isSupported ?? false
    }
}
