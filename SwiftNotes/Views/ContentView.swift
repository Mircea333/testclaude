import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            NoteListView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NoteStore())
}
