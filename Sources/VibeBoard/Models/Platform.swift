import Foundation

public struct Platform: Identifiable, Codable, Hashable, Sendable {
    public var id: String
    public var displayName: String
    public var icon: String
    public var defaultRepoName: String
    public var isBuiltIn: Bool
    public var isEnabled: Bool

    public init(
        id: String,
        displayName: String,
        icon: String = "desktopcomputer",
        defaultRepoName: String? = nil,
        isBuiltIn: Bool = false,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.displayName = displayName
        self.icon = icon
        self.defaultRepoName = defaultRepoName ?? "app-\(id.lowercased())"
        self.isBuiltIn = isBuiltIn
        self.isEnabled = isEnabled
    }

    public static let macOS = Platform(id: "macOS", displayName: "macOS", icon: "desktopcomputer", defaultRepoName: "app-macos", isBuiltIn: true)
    public static let windows = Platform(id: "windows", displayName: "Windows", icon: "pc", defaultRepoName: "app-windows", isBuiltIn: true)
    public static let linux = Platform(id: "linux", displayName: "Linux", icon: "server.rack", defaultRepoName: "app-linux", isBuiltIn: true)
    public static let android = Platform(id: "android", displayName: "Android", icon: "smartphone", defaultRepoName: "app-android", isBuiltIn: true)
    public static let ios = Platform(id: "ios", displayName: "iOS", icon: "iphone", defaultRepoName: "app-ios", isBuiltIn: true)

    public static let builtInAll: [Platform] = [.macOS, .windows, .linux, .android, .ios]
}
