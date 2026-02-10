import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var noteStore: NoteStore
    @State private var searchText = ""
    @State private var showingNewNote = false
    @State private var viewMode: ViewMode = .list
    @State private var activeFilter: NoteFilter = .all
    @State private var sortOrder: NoteSortOrder = .updatedNewest

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var filteredNotes: [Note] {
        let filtered = noteStore.filtered(by: activeFilter, searchQuery: searchText)
        return noteStore.sorted(filtered, by: sortOrder)
    }

    var body: some View {
        VStack(spacing: 0) {
            filterBar

            if filteredNotes.isEmpty {
                emptyStateView
                    .frame(maxHeight: .infinity)
            } else {
                switch viewMode {
                case .list:
                    listView
                case .grid:
                    gridView
                }
            }
        }
        .navigationTitle("Notes")
        .searchable(text: $searchText, prompt: "Search notes")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                sortMenu
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                viewModeToggle
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

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NoteFilter.allCases, id: \.self) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func filterChip(_ filter: NoteFilter) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                activeFilter = filter
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: filter.iconName)
                    .font(.caption2)
                Text(filter.label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(activeFilter == filter ? Color.accentColor : Color(.tertiarySystemFill))
            .foregroundColor(activeFilter == filter ? .white : .primary)
            .cornerRadius(16)
        }
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Menu {
            ForEach(NoteSortOrder.allCases, id: \.self) { order in
                Button {
                    sortOrder = order
                } label: {
                    HStack {
                        Text(order.label)
                        if sortOrder == order {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }

    // MARK: - View Mode Toggle

    private var viewModeToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewMode = viewMode == .list ? .grid : .list
            }
        } label: {
            Image(systemName: viewMode == .list ? ViewMode.grid.iconName : ViewMode.list.iconName)
        }
    }

    // MARK: - List View

    private var listView: some View {
        List {
            ForEach(filteredNotes) { note in
                NavigationLink(destination: NoteEditorView(note: note, isNew: false)) {
                    NoteRowView(note: note)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        noteStore.toggleFlag(note)
                    } label: {
                        Label(
                            note.isFlagged ? "Unflag" : "Flag",
                            systemImage: note.isFlagged ? "flag.slash" : "flag.fill"
                        )
                    }
                    .tint(.orange)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        noteStore.delete(note)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .contextMenu {
                    flagContextMenuItem(for: note)
                    priorityContextMenu(for: note)
                    Divider()
                    Button(role: .destructive) {
                        noteStore.delete(note)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Grid View

    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(filteredNotes) { note in
                    NavigationLink(destination: NoteEditorView(note: note, isNew: false)) {
                        NoteGridItemView(note: note)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        flagContextMenuItem(for: note)
                        priorityContextMenu(for: note)
                        Divider()
                        Button(role: .destructive) {
                            noteStore.delete(note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Context Menu Items

    private func flagContextMenuItem(for note: Note) -> some View {
        Button {
            noteStore.toggleFlag(note)
        } label: {
            Label(
                note.isFlagged ? "Remove Flag" : "Flag",
                systemImage: note.isFlagged ? "flag.slash" : "flag.fill"
            )
        }
    }

    private func priorityContextMenu(for note: Note) -> some View {
        Menu {
            ForEach(NotePriority.allCases, id: \.self) { priority in
                Button {
                    noteStore.setPriority(note, priority: priority)
                } label: {
                    HStack {
                        if priority != .none {
                            Image(systemName: priority.iconName)
                        }
                        Text(priority.label)
                        if note.priority == priority {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label("Priority", systemImage: "exclamationmark.3")
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: iconForEmptyState)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(titleForEmptyState)
                .font(.title2)
                .fontWeight(.semibold)

            Text(subtitleForEmptyState)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var iconForEmptyState: String {
        switch activeFilter {
        case .all:
            return searchText.isEmpty ? "note.text" : "magnifyingglass"
        case .flagged:
            return "flag"
        case .hasReminder:
            return "bell"
        case .highPriority:
            return "exclamationmark.3"
        }
    }

    private var titleForEmptyState: String {
        if !searchText.isEmpty {
            return "No Results"
        }
        switch activeFilter {
        case .all: return "No Notes Yet"
        case .flagged: return "No Flagged Notes"
        case .hasReminder: return "No Reminders"
        case .highPriority: return "No High Priority Notes"
        }
    }

    private var subtitleForEmptyState: String {
        if !searchText.isEmpty {
            return "No notes match \"\(searchText)\"."
        }
        switch activeFilter {
        case .all: return "Tap the compose button to create your first note."
        case .flagged: return "Swipe right on a note or use the context menu to flag it."
        case .hasReminder: return "Add reminders to notes in the note editor."
        case .highPriority: return "Set a note's priority to High in the editor or context menu."
        }
    }
}

#Preview {
    NavigationStack {
        NoteListView()
            .environmentObject(NoteStore())
    }
}
