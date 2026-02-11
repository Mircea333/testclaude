import Foundation

class NotebookStore: ObservableObject {
    @Published var notebooks: [Notebook] = []
    @Published var tags: [Tag] = []

    init() {
        loadNotebooks()
        loadTags()
    }

    // MARK: - Notebook CRUD

    func addNotebook(_ notebook: Notebook) {
        var newNotebook = notebook
        newNotebook.sortOrder = notebooks.count
        notebooks.append(newNotebook)
        saveNotebooks()
    }

    func updateNotebook(_ notebook: Notebook) {
        if let index = notebooks.firstIndex(where: { $0.id == notebook.id }) {
            notebooks[index] = notebook
            saveNotebooks()
        }
    }

    func deleteNotebook(_ notebook: Notebook) {
        notebooks.removeAll { $0.id == notebook.id }
        saveNotebooks()
    }

    // MARK: - Tag CRUD

    func addTag(_ tag: Tag) {
        tags.append(tag)
        saveTags()
    }

    func updateTag(_ tag: Tag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
            saveTags()
        }
    }

    func deleteTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
        saveTags()
    }

    func tag(for id: UUID) -> Tag? {
        tags.first { $0.id == id }
    }

    func tags(for ids: [UUID]) -> [Tag] {
        ids.compactMap { id in tags.first { $0.id == id } }
    }

    // MARK: - Notebook Persistence

    private var notebooksFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("notebooks.json")
    }

    private func saveNotebooks() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(notebooks)
            try data.write(to: notebooksFileURL, options: .atomic)
        } catch {
            print("Failed to save notebooks: \(error.localizedDescription)")
        }
    }

    private func loadNotebooks() {
        do {
            let data = try Data(contentsOf: notebooksFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            notebooks = try decoder.decode([Notebook].self, from: data)
        } catch {
            notebooks = []
        }
    }

    // MARK: - Tag Persistence

    private var tagsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("tags.json")
    }

    private func saveTags() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(tags)
            try data.write(to: tagsFileURL, options: .atomic)
        } catch {
            print("Failed to save tags: \(error.localizedDescription)")
        }
    }

    private func loadTags() {
        do {
            let data = try Data(contentsOf: tagsFileURL)
            let decoder = JSONDecoder()
            tags = try decoder.decode([Tag].self, from: data)
        } catch {
            tags = []
        }
    }
}
