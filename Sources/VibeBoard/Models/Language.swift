import Foundation

public struct Language: Identifiable, Codable, Sendable {
    public var id: String
    public var displayName: String
    public var icon: String

    public init(
        id: String,
        displayName: String? = nil,
        icon: String = "text.page.slash"
    ) {
        self.id = id
        self.displayName = displayName ?? id
        self.icon = icon
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(String.self, forKey: .id) ?? ""
        displayName = try c.decodeIfPresent(String.self, forKey: .displayName) ?? id
        icon = try c.decodeIfPresent(String.self, forKey: .icon) ?? "text.page.slash"
    }

    public static let builtInAll: [Language] = []
}

extension Language: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Language, rhs: Language) -> Bool {
        lhs.id == rhs.id
    }
}
