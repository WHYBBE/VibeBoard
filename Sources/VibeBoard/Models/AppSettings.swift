import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case zh
    case en

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .zh: return "中文"
        case .en: return "English"
        }
    }

    public var locale: Locale {
        switch self {
        case .zh: return Locale(identifier: "zh_CN")
        case .en: return Locale(identifier: "en_US")
        }
    }
}

public enum AppTheme: String, CaseIterable, Identifiable, Codable, Sendable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
