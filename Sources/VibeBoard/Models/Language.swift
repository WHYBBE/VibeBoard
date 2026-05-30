import Foundation

public struct Language: Identifiable, Codable, Hashable, Sendable {
    public var id: String
    public var displayName: String
    public var icon: String
    public var isBuiltIn: Bool
    public var isEnabled: Bool

    public init(
        id: String,
        displayName: String? = nil,
        icon: String = "text.page.slash",
        isBuiltIn: Bool = false,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.displayName = displayName ?? id
        self.icon = icon
        self.isBuiltIn = isBuiltIn
        self.isEnabled = isEnabled
    }

    public static let cSharp = Language(id: "C#", icon: "text.page.slash", isBuiltIn: true)
    public static let cPlusPlus = Language(id: "C++", icon: "text.page.slash", isBuiltIn: true)
    public static let swift = Language(id: "Swift", icon: "swift", isBuiltIn: true)

    public static let builtInAll: [Language] = [.cSharp, .cPlusPlus, .swift]
}
