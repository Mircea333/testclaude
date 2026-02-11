import Foundation

class NoteStore: ObservableObject {
    @Published var notes: [Note] = []

    private let saveKey = "SwiftNotes_SavedNotes"

    init() {
        load()
        autoPurgeTrash(olderThanDays: 30)
    }

    // MARK: - Computed Properties

    var activeNotes: [Note] {
        notes.filter { $0.isActive }
    }

    var trashedNotes: [Note] {
        notes.filter { $0.isTrashed }
    }

    var archivedNotes: [Note] {
        notes.filter { $0.isArchived }
    }

    var pinnedNotes: [Note] {
        activeNotes.filter { $0.isPinned }
    }

    // MARK: - CRUD

    func add(_ note: Note) {
        notes.insert(note, at: 0)
        save()
    }

    func update(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        save()
    }

    func delete(_ note: Note) {
        moveToTrash(note)
    }

    func toggleFlag(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isFlagged.toggle()
            notes[index].updatedAt = Date()
            save()
        }
    }

    func setPriority(_ note: Note, priority: NotePriority) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].priority = priority
            notes[index].updatedAt = Date()
            save()
        }
    }

    func setReminder(_ note: Note, date: Date?) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].reminderDate = date
            notes[index].updatedAt = Date()
            save()
        }
    }

    // MARK: - Pin

    func togglePin(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isPinned.toggle()
            notes[index].updatedAt = Date()
            save()
        }
    }

    // MARK: - Trash

    func moveToTrash(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isTrashed = true
            notes[index].trashedAt = Date()
            notes[index].isPinned = false
            save()
        }
    }

    func restoreFromTrash(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isTrashed = false
            notes[index].trashedAt = nil
            save()
        }
    }

    func permanentlyDelete(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        save()
    }

    func emptyTrash() {
        notes.removeAll { $0.isTrashed }
        save()
    }

    func autoPurgeTrash(olderThanDays days: Int) {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let before = notes.count
        notes.removeAll { note in
            note.isTrashed && (note.trashedAt ?? Date()) < cutoff
        }
        if notes.count != before {
            save()
        }
    }

    // MARK: - Archive

    func archive(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isArchived = true
            notes[index].isPinned = false
            notes[index].updatedAt = Date()
            save()
        }
    }

    func unarchive(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isArchived = false
            notes[index].updatedAt = Date()
            save()
        }
    }

    // MARK: - Search & Filter

    func search(_ query: String) -> [Note] {
        let active = activeNotes
        guard !query.isEmpty else { return active }
        return active.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.content.localizedCaseInsensitiveContains(query)
        }
    }

    func filtered(by filter: NoteFilter, searchQuery: String, notebookID: UUID? = nil) -> [Note] {
        var result = search(searchQuery)

        if let notebookID = notebookID {
            result = result.filter { $0.notebookID == notebookID }
        }

        switch filter {
        case .all:
            break
        case .flagged:
            result = result.filter { $0.isFlagged }
        case .hasReminder:
            result = result.filter { $0.hasReminder }
        case .highPriority:
            result = result.filter { $0.priority == .high }
        }

        return result
    }

    func sorted(_ notes: [Note], by order: NoteSortOrder) -> [Note] {
        let pinned = notes.filter { $0.isPinned }
        let unpinned = notes.filter { !$0.isPinned }

        let sortedUnpinned: [Note]
        switch order {
        case .updatedNewest:
            sortedUnpinned = unpinned.sorted { $0.updatedAt > $1.updatedAt }
        case .updatedOldest:
            sortedUnpinned = unpinned.sorted { $0.updatedAt < $1.updatedAt }
        case .priorityHighFirst:
            sortedUnpinned = unpinned.sorted { $0.priority > $1.priority }
        case .priorityLowFirst:
            sortedUnpinned = unpinned.sorted { $0.priority < $1.priority }
        case .titleAZ:
            sortedUnpinned = unpinned.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleZA:
            sortedUnpinned = unpinned.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        }

        let sortedPinned = pinned.sorted { $0.updatedAt > $1.updatedAt }
        return sortedPinned + sortedUnpinned
    }

    // MARK: - Notebook/Tag Queries

    func notesInNotebook(_ id: UUID?) -> [Note] {
        activeNotes.filter { $0.notebookID == id }
    }

    func notesWithTag(_ id: UUID) -> [Note] {
        activeNotes.filter { $0.tagIDs.contains(id) }
    }

    // MARK: - Dashboard Helpers

    func recentlyModified(limit: Int = 5) -> [Note] {
        Array(activeNotes.sorted { $0.updatedAt > $1.updatedAt }.prefix(limit))
    }

    func notesThisWeek() -> [Note] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return activeNotes.filter { $0.updatedAt >= startOfWeek }
    }

    // MARK: - Data Management

    func exportNotesData() -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(notes)
        } catch {
            print("Failed to export notes: \(error.localizedDescription)")
            return nil
        }
    }

    func importNotes(from data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let importedNotes = try decoder.decode([Note].self, from: data)

        let existingIDs = Set(notes.map { $0.id })
        let newNotes = importedNotes.filter { !existingIDs.contains($0.id) }
        notes.append(contentsOf: newNotes)
        save()
    }

    func clearAllNotes() {
        notes.removeAll()
        save()
    }

    // MARK: - Persistence

    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("notes.json")
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(notes)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save notes: \(error.localizedDescription)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            notes = try decoder.decode([Note].self, from: data)
        } catch {
            notes = []
        }
    }
}
