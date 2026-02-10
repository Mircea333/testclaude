import Foundation

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), title: String = "", content: String = "", createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var preview: String {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: true)
        if let firstLine = lines.first {
            let text = String(firstLine)
            return text.count > 100 ? String(text.prefix(100)) + "..." : text
        }
        return "No additional text"
    }
}
