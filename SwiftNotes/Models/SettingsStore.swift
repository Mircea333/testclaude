import Foundation
import SwiftUI

class SettingsStore: ObservableObject {
    @Published var settings: AppSettings = AppSettings()

    var colorScheme: ColorScheme? {
        settings.colorScheme
    }

    var dynamicTypeSize: DynamicTypeSize {
        settings.fontSize.dynamicTypeSize
    }

    init() {
        load()
    }

    func resetToDefaults() {
        settings = AppSettings()
        save()
    }

    func storageInfo() -> (noteFileSize: Int64, settingsFileSize: Int64) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        let noteFileURL = documentsDirectory.appendingPathComponent("notes.json")
        let settingsFileURL = documentsDirectory.appendingPathComponent("settings.json")

        let noteSize = (try? fileManager.attributesOfItem(atPath: noteFileURL.path)[.size] as? Int64) ?? 0
        let settingsSize = (try? fileManager.attributesOfItem(atPath: settingsFileURL.path)[.size] as? Int64) ?? 0

        return (noteSize, settingsSize)
    }

    // MARK: - Persistence

    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("settings.json")
    }

    func save() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save settings: \(error.localizedDescription)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            settings = try decoder.decode(AppSettings.self, from: data)
        } catch {
            settings = AppSettings()
        }
    }
}
