import Foundation

struct UserProfile: Codable, Equatable {
    var id: UUID
    var name: String
    var email: String
    var avatarSystemName: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        email: String = "",
        avatarSystemName: String = "person.circle.fill",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarSystemName = avatarSystemName
        self.createdAt = createdAt
    }
}
