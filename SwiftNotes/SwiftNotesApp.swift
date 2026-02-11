import SwiftUI

@main
struct SwiftNotesApp: App {
    @StateObject private var noteStore = NoteStore()
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var userProfileStore = UserProfileStore()
    @StateObject private var notebookStore = NotebookStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(noteStore)
                .environmentObject(settingsStore)
                .environmentObject(userProfileStore)
                .environmentObject(notebookStore)
                .preferredColorScheme(settingsStore.colorScheme)
                .dynamicTypeSize(settingsStore.dynamicTypeSize)
        }
    }
}
