import SwiftUI

public struct S {
    nonisolated(unsafe) public static var lang: AppLanguage = .zh
    private static var isZh: Bool { lang == .zh }

    public static var sidebar: Sidebar { .init() }
    public struct Sidebar {
        var noProject: String { S.isZh ? "没有项目" : "No Projects" }
        var noProjectHint: String { S.isZh ? "点击 + 创建一个新项目" : "Click + to create a new project" }
        var newProject: String { S.isZh ? "新建项目" : "New Project" }
        var cancel: String { S.isZh ? "取消" : "Cancel" }
        var create: String { S.isZh ? "创建" : "Create" }
        var projectName: String { S.isZh ? "项目名称" : "Project Name" }
        var deleteProject: String { S.isZh ? "删除项目" : "Delete Project" }
        var deleteProjectConfirmTitle: String { S.isZh ? "确认删除项目" : "Delete Project" }
        var deleteProjectConfirmMessage: String { S.isZh ? "将删除此项目及所有相关数据，不可恢复。确定继续？" : "This project and all related data will be deleted. This cannot be undone. Continue?" }
    }

    public static var detail: Detail { .init() }
    public struct Detail {
        var selectProject: String { S.isZh ? "选择一个项目" : "Select a Project" }
        var selectProjectHint: String { S.isZh ? "从左侧选择或创建一个项目" : "Select or create a project from the sidebar" }
        var projectName: String { S.isZh ? "项目名称" : "Project Name" }
        var projectNamePlaceholder: String { S.isZh ? "输入项目名称" : "Enter project name" }
        var keywords: String { S.isZh ? "需求关键词" : "Keywords" }
        var addKeyword: String { S.isZh ? "添加关键词" : "Add keyword" }
        var add: String { S.isZh ? "添加" : "Add" }
        var languages: String { S.isZh ? "开发语言" : "Languages" }
        var platformStatus: String { S.isZh ? "各平台实现情况" : "Platform Status" }
        var addPlatform: String { S.isZh ? "添加平台" : "Add Platform" }
        var repoName: String { S.isZh ? "仓库名" : "Repo Name" }
        var implemented: String { S.isZh ? "已实现" : "Done" }
        var platformCount: String { S.isZh ? "平台" : "platforms" }
        var edit: String { S.isZh ? "编辑" : "Edit" }
        var preview: String { S.isZh ? "预览" : "Preview" }
        var supported: String { S.isZh ? "已支持" : "Supported" }
        var notSupported: String { S.isZh ? "未支持" : "Not Supported" }
        var progress: String { S.isZh ? "进度" : "Progress" }
        var noKeywords: String { S.isZh ? "暂无关键词" : "No keywords" }
        var sharedGroups: String { S.isZh ? "共享代码" : "Shared Code" }
        var addSharedGroup: String { S.isZh ? "添加共享组" : "Add Shared Group" }
        var sharedGroupName: String { S.isZh ? "组名" : "Group Name" }
        var sharedGroupPlatforms: String { S.isZh ? "共享平台" : "Shared Platforms" }
        var sharedGroupRepo: String { S.isZh ? "共享仓库" : "Shared Repo" }
        var deleteGroup: String { S.isZh ? "删除此组" : "Delete Group" }
        var deleteGroupConfirmTitle: String { S.isZh ? "确认删除共享组" : "Delete Shared Group" }
        var deleteGroupConfirmMessage: String { S.isZh ? "将删除此共享组，不可恢复。确定继续？" : "This shared group will be deleted. This cannot be undone. Continue?" }
        var deletePlatformConfirmTitle: String { S.isZh ? "确认删除平台" : "Remove Platform" }
        var deletePlatformConfirmMessage: String { S.isZh ? "将从项目中移除此平台，不可恢复。确定继续？" : "This platform will be removed from the project. This cannot be undone. Continue?" }
    }

    public static var settings: Settings { .init() }
    public struct Settings {
        var general: String { S.isZh ? "通用" : "General" }
        var platform: String { S.isZh ? "平台" : "Platforms" }
        var language: String { S.isZh ? "语言" : "Languages" }
        var icon: String { S.isZh ? "图标" : "Icon" }
        var name: String { S.isZh ? "名称" : "Name" }
        var repoName: String { S.isZh ? "仓库名" : "Repo Name" }
        var displayName: String { S.isZh ? "显示名" : "Display Name" }
        var deletePlatform: String { S.isZh ? "删除此平台" : "Delete Platform" }
        var deleteLanguage: String { S.isZh ? "删除此语言" : "Delete Language" }
        var addCustomPlatform: String { S.isZh ? "添加自定义平台" : "Add Custom Platform" }
        var addCustomLanguage: String { S.isZh ? "添加自定义语言" : "Add Custom Language" }
        var customize: String { S.isZh ? "自定义..." : "Custom..." }
        var defaultEnabled: String { S.isZh ? "默认启用" : "Default On" }
        var appLanguage: String { S.isZh ? "界面语言" : "Interface Language" }
        var theme: String { S.isZh ? "主题" : "Theme" }
        var themeSystem: String { S.isZh ? "跟随系统" : "System" }
        var themeLight: String { S.isZh ? "浅色" : "Light" }
        var themeDark: String { S.isZh ? "深色" : "Dark" }
        var exportData: String { S.isZh ? "导出数据" : "Export Data" }
        var importData: String { S.isZh ? "导入数据" : "Import Data" }
        var exportSuccess: String { S.isZh ? "导出成功" : "Export Succeeded" }
        var exportFail: String { S.isZh ? "导出失败" : "Export Failed" }
        var importSuccess: String { S.isZh ? "导入成功" : "Import Succeeded" }
        var importFail: String { S.isZh ? "导入失败：文件格式无效" : "Import Failed: Invalid file format" }
        var dataManagement: String { S.isZh ? "数据管理" : "Data Management" }
        var clearData: String { S.isZh ? "清空数据" : "Clear Data" }
        var clearConfirmTitle: String { S.isZh ? "确认清空" : "Confirm Clear" }
        var clearConfirmMessage: String { S.isZh ? "将删除所有项目、自定义平台和语言，不可恢复。确定继续？" : "All projects, custom platforms and languages will be deleted. This cannot be undone. Continue?" }
        var clearSuccess: String { S.isZh ? "已清空" : "Cleared" }
        var deleteCustomPlatformConfirmTitle: String { S.isZh ? "确认删除自定义平台" : "Delete Custom Platform" }
        var deleteCustomPlatformConfirmMessage: String { S.isZh ? "将删除此自定义平台及项目中相关数据，不可恢复。确定继续？" : "This custom platform and related project data will be deleted. This cannot be undone. Continue?" }
        var deleteCustomLanguageConfirmTitle: String { S.isZh ? "确认删除自定义语言" : "Delete Custom Language" }
        var deleteCustomLanguageConfirmMessage: String { S.isZh ? "将删除此自定义语言及项目中相关数据，不可恢复。确定继续？" : "This custom language and related project data will be deleted. This cannot be undone. Continue?" }
    }
}
