import Foundation

public struct LLMTag: Identifiable, Codable, Sendable {
    public var id: String
    public var displayName: String
    public var icon: String

    public init(
        id: String,
        displayName: String? = nil,
        icon: String = "cpu"
    ) {
        self.id = id
        self.displayName = displayName ?? id
        self.icon = icon
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(String.self, forKey: .id) ?? ""
        displayName = try c.decodeIfPresent(String.self, forKey: .displayName) ?? id
        icon = try c.decodeIfPresent(String.self, forKey: .icon) ?? "cpu"
    }

    public static let builtInAll: [LLMTag] = []
}

extension LLMTag: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: LLMTag, rhs: LLMTag) -> Bool {
        lhs.id == rhs.id
    }
}
