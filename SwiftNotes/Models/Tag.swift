import Foundation
import SwiftUI

struct Tag: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var colorName: String

    init(
        id: UUID = UUID(),
        name: String = "",
        colorName: String = "blue"
    ) {
        self.id = id
        self.name = name
        self.colorName = colorName
    }

    var color: Color {
        switch colorName {
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "red": return .red
        case "orange": return .orange
        case "green": return .green
        case "teal": return .teal
        case "indigo": return .indigo
        default: return .blue
        }
    }
}
