import Foundation

enum NoteBlockType: String, Codable {
    case text
    case heading
    case bulletList
    case numberedList
    case checklist
    case image
    case divider
}

struct TextFormatting: Codable, Equatable {
    var isBold: Bool = false
    var isItalic: Bool = false
    var isUnderline: Bool = false
}

struct NoteBlock: Identifiable, Codable, Equatable {
    let id: UUID
    var type: NoteBlockType
    var text: String
    var formatting: TextFormatting
    var isChecked: Bool
    var imageFileName: String?
    var listIndex: Int?

    init(
        id: UUID = UUID(),
        type: NoteBlockType = .text,
        text: String = "",
        formatting: TextFormatting = TextFormatting(),
        isChecked: Bool = false,
        imageFileName: String? = nil,
        listIndex: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.text = text
        self.formatting = formatting
        self.isChecked = isChecked
        self.imageFileName = imageFileName
        self.listIndex = listIndex
    }
}
