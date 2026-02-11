import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject var noteStore: NoteStore

    var body: some View {
        List {
            if noteStore.archivedNotes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No Archived Notes")
                        .font(.title2.bold())
                    Text("Archived notes will appear here. Archive notes you want to keep but don't need quick access to.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowSeparator(.hidden)
            } else {
                ForEach(noteStore.archivedNotes) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(note.title.isEmpty ? "Untitled" : note.title)
                                .font(.headline)
                                .lineLimit(1)

                            if note.isFlagged {
                                Image(systemName: "flag.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }

                        Text(note.preview)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)

                        Text("Archived \(note.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .leading) {
                        Button {
                            noteStore.unarchive(note)
                        } label: {
                            Label("Unarchive", systemImage: "arrow.uturn.backward")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            noteStore.moveToTrash(note)
                        } label: {
                            Label("Trash", systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button {
                            noteStore.unarchive(note)
                        } label: {
                            Label("Unarchive", systemImage: "arrow.uturn.backward")
                        }

                        Button(role: .destructive) {
                            noteStore.moveToTrash(note)
                        } label: {
                            Label("Move to Trash", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Archive")
    }
}

#Preview {
    NavigationStack {
        ArchiveView()
            .environmentObject(NoteStore())
    }
}
