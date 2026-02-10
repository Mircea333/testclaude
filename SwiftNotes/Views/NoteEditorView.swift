import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject var noteStore: NoteStore
    @Environment(\.dismiss) private var dismiss

    @State var note: Note
    let isNew: Bool

    @State private var showingDeleteAlert = false
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            TextField("Title", text: $note.title)
                .font(.title2.bold())
                .padding(.horizontal)
                .padding(.top, 12)
                .focused($isTitleFocused)

            Divider()
                .padding(.horizontal)
                .padding(.vertical, 8)

            TextEditor(text: $note.content)
                .font(.body)
                .padding(.horizontal, 12)
                .scrollContentBackground(.hidden)
        }
        .navigationTitle(isNew ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNew {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .fontWeight(.semibold)
                    .disabled(note.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Note", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            if isNew {
                isTitleFocused = true
            }
        }
        .onDisappear {
            if !isNew {
                saveExistingNote()
            }
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                noteStore.delete(note)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }

    private func saveNote() {
        let trimmedTitle = note.title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        note.title = trimmedTitle
        note.updatedAt = Date()
        noteStore.add(note)
        dismiss()
    }

    private func saveExistingNote() {
        note.updatedAt = Date()
        noteStore.update(note)
    }
}

#Preview {
    NavigationStack {
        NoteEditorView(note: Note(title: "Sample", content: "Hello world"), isNew: false)
            .environmentObject(NoteStore())
    }
}
