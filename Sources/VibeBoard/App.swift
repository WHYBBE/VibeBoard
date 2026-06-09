import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        if let raw = UserDefaults.standard.string(forKey: "VB_appTheme"),
           let theme = AppTheme(rawValue: raw) {
            switch theme {
            case .dark: NSApp.appearance = NSAppearance(named: .darkAqua)
            case .light: NSApp.appearance = NSAppearance(named: .aqua)
            case .system: NSApp.appearance = nil
            }
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        for window in NSApp.windows {
            window.orderOut(nil)
        }

        NSApp.setActivationPolicy(.regular)

        // 延迟显示窗口，避免 NavigationSplitView 首次布局时 sidebar 折叠动画导致的闪亮
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            for window in NSApp.windows {
                window.makeKeyAndOrderFront(nil)
            }
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

@main
struct VibeBoardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = VibeBoardStore()

    var body: some Scene {
        WindowGroup {
            VibeBoardView(store: store)
                .environment(\.locale, store.appLanguage.locale)
                .preferredColorScheme(store.appTheme.colorScheme)
                .frame(minWidth: 800, minHeight: 500)
        }

        Settings {
            SettingsView(store: store)
                .frame(minWidth: 400, maxWidth: 520, minHeight: 400)
                .environment(\.locale, store.appLanguage.locale)
                .preferredColorScheme(store.appTheme.colorScheme)
        }
    }
}
