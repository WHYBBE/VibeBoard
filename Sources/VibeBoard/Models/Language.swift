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
