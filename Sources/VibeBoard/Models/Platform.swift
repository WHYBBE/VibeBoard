import Foundation

public struct Platform: Identifiable, Codable, Hashable, Sendable {
    public var id: String
    public var displayName: String
    public var icon: String
    public var isBuiltIn: Bool
    public var isEnabled: Bool

    public init(
        id: String,
        displayName: String,
        icon: String = "desktopcomputer",
        isBuiltIn: Bool = false,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.displayName = displayName
        self.icon = icon
        self.isBuiltIn = isBuiltIn
        self.isEnabled = isEnabled
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(String.self, forKey: .id) ?? ""
        displayName = try c.decodeIfPresent(String.self, forKey: .displayName) ?? id
        icon = try c.decodeIfPresent(String.self, forKey: .icon) ?? "desktopcomputer"
        isBuiltIn = try c.decodeIfPresent(Bool.self, forKey: .isBuiltIn) ?? false
        isEnabled = try c.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
    }

    public static let macOS = Platform(id: "macOS", displayName: "macOS", icon: "desktopcomputer", isBuiltIn: true)
    public static let windows = Platform(id: "windows", displayName: "Windows", icon: "pc", isBuiltIn: true)
    public static let linux = Platform(id: "linux", displayName: "Linux", icon: "server.rack", isBuiltIn: true)
    public static let android = Platform(id: "android", displayName: "Android", icon: "smartphone", isBuiltIn: true, isEnabled: false)
    public static let ios = Platform(id: "ios", displayName: "iOS", icon: "iphone", isBuiltIn: true, isEnabled: false)
    public static let web = Platform(id: "web", displayName: "Web", icon: "globe", isBuiltIn: true, isEnabled: false)

    public static let builtInAll: [Platform] = [.macOS, .windows, .linux, .android, .ios, .web]
}
