import Foundation

class NoteStore: ObservableObject {
    @Published var notes: [Note] = []

    private let saveKey = "SwiftNotes_SavedNotes"

    init() {
        load()
    }

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
        notes.removeAll { $0.id == note.id }
        save()
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

    func search(_ query: String) -> [Note] {
        guard !query.isEmpty else { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.content.localizedCaseInsensitiveContains(query)
        }
    }

    func filtered(by filter: NoteFilter, searchQuery: String) -> [Note] {
        var result = search(searchQuery)

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
        switch order {
        case .updatedNewest:
            return notes.sorted { $0.updatedAt > $1.updatedAt }
        case .updatedOldest:
            return notes.sorted { $0.updatedAt < $1.updatedAt }
        case .priorityHighFirst:
            return notes.sorted { $0.priority > $1.priority }
        case .priorityLowFirst:
            return notes.sorted { $0.priority < $1.priority }
        case .titleAZ:
            return notes.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleZA:
            return notes.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        }
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
