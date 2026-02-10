import Foundation

enum NotePriority: Int, Codable, CaseIterable, Comparable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3

    var label: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var iconName: String {
        switch self {
        case .none: return ""
        case .low: return "arrow.down"
        case .medium: return "equal"
        case .high: return "exclamationmark.3"
        }
    }

    var color: String {
        switch self {
        case .none: return "secondary"
        case .low: return "blue"
        case .medium: return "orange"
        case .high: return "red"
        }
    }

    static func < (lhs: NotePriority, rhs: NotePriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum ViewMode: String, CaseIterable {
    case list
    case grid

    var iconName: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
}

enum NoteFilter: String, CaseIterable {
    case all
    case flagged
    case hasReminder
    case highPriority

    var label: String {
        switch self {
        case .all: return "All Notes"
        case .flagged: return "Flagged"
        case .hasReminder: return "Reminders"
        case .highPriority: return "High Priority"
        }
    }

    var iconName: String {
        switch self {
        case .all: return "tray.full"
        case .flagged: return "flag.fill"
        case .hasReminder: return "bell.fill"
        case .highPriority: return "exclamationmark.3"
        }
    }
}

enum NoteSortOrder: String, CaseIterable {
    case updatedNewest
    case updatedOldest
    case priorityHighFirst
    case priorityLowFirst
    case titleAZ
    case titleZA

    var label: String {
        switch self {
        case .updatedNewest: return "Newest First"
        case .updatedOldest: return "Oldest First"
        case .priorityHighFirst: return "Priority: High to Low"
        case .priorityLowFirst: return "Priority: Low to High"
        case .titleAZ: return "Title: A-Z"
        case .titleZA: return "Title: Z-A"
        }
    }
}

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var priority: NotePriority
    var isFlagged: Bool
    var reminderDate: Date?

    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        priority: NotePriority = .none,
        isFlagged: Bool = false,
        reminderDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.priority = priority
        self.isFlagged = isFlagged
        self.reminderDate = reminderDate
    }

    var preview: String {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: true)
        if let firstLine = lines.first {
            let text = String(firstLine)
            return text.count > 100 ? String(text.prefix(100)) + "..." : text
        }
        return "No additional text"
    }

    var hasReminder: Bool {
        reminderDate != nil
    }

    var isReminderOverdue: Bool {
        guard let reminderDate = reminderDate else { return false }
        return reminderDate < Date()
    }
}
