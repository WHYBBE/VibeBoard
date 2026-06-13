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

    public static let macOS = Platform(id: "macOS", displayName: "macOS", icon: "desktopcomputer", isBuiltIn: true)
    public static let windows = Platform(id: "windows", displayName: "Windows", icon: "pc", isBuiltIn: true)
    public static let linux = Platform(id: "linux", displayName: "Linux", icon: "server.rack", isBuiltIn: true)
    public static let android = Platform(id: "android", displayName: "Android", icon: "smartphone", isBuiltIn: true, isEnabled: false)
    public static let ios = Platform(id: "ios", displayName: "iOS", icon: "iphone", isBuiltIn: true, isEnabled: false)
    public static let web = Platform(id: "web", displayName: "Web", icon: "globe", isBuiltIn: true, isEnabled: false)

    public static let builtInAll: [Platform] = [.macOS, .windows, .linux, .android, .ios, .web]
}
