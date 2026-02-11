import Foundation
import SwiftUI

enum AppearanceMode: String, Codable, CaseIterable {
    case system
    case light
    case dark

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

enum FontSizePreference: String, Codable, CaseIterable {
    case small
    case medium
    case large

    var label: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }

    var dynamicTypeSize: DynamicTypeSize {
        switch self {
        case .small: return .small
        case .medium: return .medium
        case .large: return .xxxLarge
        }
    }
}

struct AppSettings: Codable, Equatable {
    // Appearance
    var appearanceMode: AppearanceMode = .system
    var fontSize: FontSizePreference = .medium
    var accentColorName: String = "blue"

    // Note Defaults
    var defaultPriority: NotePriority = .none
    var defaultSortOrder: NoteSortOrder = .updatedNewest
    var defaultViewMode: ViewMode = .list

    // Notifications
    var notificationsEnabled: Bool = true
    var defaultReminderHour: Int = 9
    var defaultReminderMinute: Int = 0
    var reminderSoundEnabled: Bool = true

    // Trash
    var autoDeleteTrashDays: Int = 30

    var colorScheme: ColorScheme? {
        switch appearanceMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
