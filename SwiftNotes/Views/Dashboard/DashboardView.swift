import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var noteStore: NoteStore
    @EnvironmentObject var notebookStore: NotebookStore
    @State private var showingNewNote = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Stats Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    StatCardView(
                        title: "Total Notes",
                        value: "\(noteStore.activeNotes.count)",
                        iconName: "note.text",
                        color: .blue
                    )
                    StatCardView(
                        title: "This Week",
                        value: "\(noteStore.notesThisWeek().count)",
                        iconName: "calendar",
                        color: .green
                    )
                    StatCardView(
                        title: "Flagged",
                        value: "\(noteStore.activeNotes.filter { $0.isFlagged }.count)",
                        iconName: "flag.fill",
                        color: .orange
                    )
                    StatCardView(
                        title: "Archived",
                        value: "\(noteStore.archivedNotes.count)",
                        iconName: "archivebox",
                        color: .purple
                    )
                    StatCardView(
                        title: "Notebooks",
                        value: "\(notebookStore.notebooks.count)",
                        iconName: "folder",
                        color: .teal
                    )
                    StatCardView(
                        title: "Tags",
                        value: "\(notebookStore.tags.count)",
                        iconName: "tag",
                        color: .indigo
                    )
                }
                .padding(.horizontal)
            }

            // Pinned Notes
            if !noteStore.pinnedNotes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pinned")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(noteStore.pinnedNotes) { note in
                                NavigationLink(destination: NoteEditorView(note: note, isNew: false)) {
                                    pinnedNoteCard(note)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            // Quick Actions
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Actions")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    QuickActionsView(
                        onNewNote: { showingNewNote = true },
                        onNewChecklist: { showingNewNote = true }
                    )
                    .padding(.horizontal)
                }
            }

            // Recent Activity
            if !noteStore.recentlyModified().isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Activity")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(noteStore.recentlyModified()) { note in
                        NavigationLink(destination: NoteEditorView(note: note, isNew: false)) {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "pencil")
                                            .font(.caption)
                                            .foregroundColor(.accentColor)
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(note.title.isEmpty ? "Untitled" : note.title)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingNewNote) {
            NavigationStack {
                NoteEditorView(note: Note(), isNew: true)
            }
        }
    }

    private func pinnedNoteCard(_ note: Note) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "pin.fill")
                    .font(.caption2)
                    .foregroundColor(.accentColor)
                Spacer()
            }

            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.subheadline.bold())
                .lineLimit(1)

            Text(note.preview)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(10)
        .frame(width: 150, height: 90)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environmentObject(NoteStore())
            .environmentObject(NotebookStore())
    }
}
