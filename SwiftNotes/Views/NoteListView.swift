import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var noteStore: NoteStore
    @State private var searchText = ""
    @State private var showingNewNote = false

    var filteredNotes: [Note] {
        noteStore.search(searchText)
    }

    var body: some View {
        List {
            if filteredNotes.isEmpty {
                emptyStateView
            } else {
                ForEach(filteredNotes) { note in
                    NavigationLink(destination: NoteEditorView(note: note, isNew: false)) {
                        NoteRowView(note: note)
                    }
                }
                .onDelete { offsets in
                    let notesToDelete = offsets.map { filteredNotes[$0] }
                    for note in notesToDelete {
                        noteStore.delete(note)
                    }
                }
            }
        }
        .navigationTitle("Notes")
        .searchable(text: $searchText, prompt: "Search notes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingNewNote = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showingNewNote) {
            NavigationStack {
                NoteEditorView(note: Note(), isNew: true)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "note.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            if searchText.isEmpty {
                Text("No Notes Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Tap the compose button to create your first note.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("No Results")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("No notes match \"\(searchText)\".")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    NavigationStack {
        NoteListView()
            .environmentObject(NoteStore())
    }
}
