import Foundation

class UserProfileStore: ObservableObject {
    @Published var profile: UserProfile?

    var isLoggedIn: Bool {
        profile != nil
    }

    init() {
        load()
    }

    func signUp(name: String, email: String) {
        let newProfile = UserProfile(name: name, email: email)
        profile = newProfile
        save()
    }

    func logIn(name: String, email: String) {
        let existingProfile = UserProfile(name: name, email: email)
        profile = existingProfile
        save()
    }

    func updateProfile(_ updatedProfile: UserProfile) {
        profile = updatedProfile
        save()
    }

    func logOut() {
        profile = nil
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: fileURL)
        }
    }

    // MARK: - Persistence

    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("user_profile.json")
    }

    private func save() {
        guard let profile = profile else { return }
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(profile)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save profile: \(error.localizedDescription)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            profile = try decoder.decode(UserProfile.self, from: data)
        } catch {
            profile = nil
        }
    }
}
