import Foundation

public struct LLMTag: Identifiable, Codable, Hashable, Sendable {
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

    public static let builtInAll: [LLMTag] = []
}
