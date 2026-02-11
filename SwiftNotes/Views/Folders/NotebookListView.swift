import SwiftUI

struct NotebookListView: View {
    @EnvironmentObject var notebookStore: NotebookStore
    @EnvironmentObject var noteStore: NoteStore
    @State private var showingAddNotebook = false
    @State private var editingNotebook: Notebook?

    var body: some View {
        List {
            if notebookStore.notebooks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No Notebooks")
                        .font(.headline)
                    Text("Create a notebook to organize your notes.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowSeparator(.hidden)
            } else {
                ForEach(notebookStore.notebooks) { notebook in
                    HStack(spacing: 12) {
                        Image(systemName: notebook.iconName)
                            .foregroundColor(colorForName(notebook.colorName))
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(notebook.name)
                                .font(.headline)
                            Text("\(noteCount(for: notebook)) notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .contextMenu {
                        Button {
                            editingNotebook = notebook
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            notebookStore.deleteNotebook(notebook)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            notebookStore.deleteNotebook(notebook)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Notebooks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddNotebook = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddNotebook) {
            NavigationStack {
                NotebookEditorView(notebook: Notebook(), isNew: true)
            }
        }
        .sheet(item: $editingNotebook) { notebook in
            NavigationStack {
                NotebookEditorView(notebook: notebook, isNew: false)
            }
        }
    }

    private func noteCount(for notebook: Notebook) -> Int {
        noteStore.notes.filter { $0.notebookID == notebook.id && $0.isActive }.count
    }

    private func colorForName(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "red": return .red
        case "orange": return .orange
        case "green": return .green
        case "teal": return .teal
        case "indigo": return .indigo
        default: return .blue
        }
    }
}

#Preview {
    NavigationStack {
        NotebookListView()
            .environmentObject(NotebookStore())
            .environmentObject(NoteStore())
    }
}
