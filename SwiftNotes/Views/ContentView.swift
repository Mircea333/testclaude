import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userProfileStore: UserProfileStore

    var body: some View {
        if userProfileStore.isLoggedIn {
            NavigationStack {
                NoteListView()
            }
        } else {
            NavigationStack {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NoteStore())
        .environmentObject(SettingsStore())
        .environmentObject(UserProfileStore())
}
