import Foundation

struct Notebook: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var iconName: String
    var colorName: String
    var createdAt: Date
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String = "New Notebook",
        iconName: String = "folder",
        colorName: String = "blue",
        createdAt: Date = Date(),
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorName = colorName
        self.createdAt = createdAt
        self.sortOrder = sortOrder
    }
}
