import SwiftUI

struct TrashView: View {
    @EnvironmentObject var noteStore: NoteStore
    @State private var showingEmptyTrashAlert = false

    var body: some View {
        List {
            if noteStore.trashedNotes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Trash is Empty")
                        .font(.title2.bold())
                    Text("Deleted notes will appear here for 30 days before being permanently removed.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowSeparator(.hidden)
            } else {
                ForEach(noteStore.trashedNotes) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title.isEmpty ? "Untitled" : note.title)
                            .font(.headline)
                            .lineLimit(1)

                        Text(note.preview)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)

                        if let trashedAt = note.trashedAt {
                            Text(daysRemainingText(trashedAt: trashedAt))
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .leading) {
                        Button {
                            noteStore.restoreFromTrash(note)
                        } label: {
                            Label("Restore", systemImage: "arrow.uturn.backward")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            noteStore.permanentlyDelete(note)
                        } label: {
                            Label("Delete Forever", systemImage: "trash.slash")
                        }
                    }
                    .contextMenu {
                        Button {
                            noteStore.restoreFromTrash(note)
                        } label: {
                            Label("Restore", systemImage: "arrow.uturn.backward")
                        }

                        Button(role: .destructive) {
                            noteStore.permanentlyDelete(note)
                        } label: {
                            Label("Delete Permanently", systemImage: "trash.slash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Trash")
        .toolbar {
            if !noteStore.trashedNotes.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Empty Trash", role: .destructive) {
                        showingEmptyTrashAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .alert("Empty Trash", isPresented: $showingEmptyTrashAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Empty Trash", role: .destructive) {
                noteStore.emptyTrash()
            }
        } message: {
            Text("This will permanently delete \(noteStore.trashedNotes.count) note(s). This action cannot be undone.")
        }
    }

    private func daysRemainingText(trashedAt: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: trashedAt, to: Date()).day ?? 0
        let remaining = max(0, 30 - days)
        if remaining == 0 {
            return "Will be deleted soon"
        }
        return "Auto-deletes in \(remaining) day\(remaining == 1 ? "" : "s")"
    }
}

#Preview {
    NavigationStack {
        TrashView()
            .environmentObject(NoteStore())
    }
}
