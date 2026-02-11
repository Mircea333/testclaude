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

enum ViewMode: String, Codable, CaseIterable {
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

enum NoteSortOrder: String, Codable, CaseIterable {
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
    var notebookID: UUID?
    var tagIDs: [UUID]
    var isTrashed: Bool
    var isArchived: Bool
    var trashedAt: Date?
    var isPinned: Bool
    var blocks: [NoteBlock]?

    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        priority: NotePriority = .none,
        isFlagged: Bool = false,
        reminderDate: Date? = nil,
        notebookID: UUID? = nil,
        tagIDs: [UUID] = [],
        isTrashed: Bool = false,
        isArchived: Bool = false,
        trashedAt: Date? = nil,
        isPinned: Bool = false,
        blocks: [NoteBlock]? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.priority = priority
        self.isFlagged = isFlagged
        self.reminderDate = reminderDate
        self.notebookID = notebookID
        self.tagIDs = tagIDs
        self.isTrashed = isTrashed
        self.isArchived = isArchived
        self.trashedAt = trashedAt
        self.isPinned = isPinned
        self.blocks = blocks
    }

    // Backward-compatible decoding for existing JSON data
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        priority = try container.decode(NotePriority.self, forKey: .priority)
        isFlagged = try container.decode(Bool.self, forKey: .isFlagged)
        reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
        notebookID = try container.decodeIfPresent(UUID.self, forKey: .notebookID)
        tagIDs = try container.decodeIfPresent([UUID].self, forKey: .tagIDs) ?? []
        isTrashed = try container.decodeIfPresent(Bool.self, forKey: .isTrashed) ?? false
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        trashedAt = try container.decodeIfPresent(Date.self, forKey: .trashedAt)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        blocks = try container.decodeIfPresent([NoteBlock].self, forKey: .blocks)
    }

    var isActive: Bool {
        !isTrashed && !isArchived
    }

    var preview: String {
        let text = displayContent
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        if let firstLine = lines.first {
            let lineText = String(firstLine)
            return lineText.count > 100 ? String(lineText.prefix(100)) + "..." : lineText
        }
        return "No additional text"
    }

    var displayContent: String {
        if let blocks = blocks, !blocks.isEmpty {
            return blocks
                .filter { $0.type != .image && $0.type != .divider }
                .map { $0.text }
                .joined(separator: "\n")
        }
        return content
    }

    var hasRichContent: Bool {
        blocks != nil && !(blocks?.isEmpty ?? true)
    }

    var hasReminder: Bool {
        reminderDate != nil
    }

    var isReminderOverdue: Bool {
        guard let reminderDate = reminderDate else { return false }
        return reminderDate < Date()
    }
}
