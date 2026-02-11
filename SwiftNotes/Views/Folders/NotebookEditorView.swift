import SwiftUI

struct NotebookEditorView: View {
    @EnvironmentObject var notebookStore: NotebookStore
    @Environment(\.dismiss) private var dismiss
    @State var notebook: Notebook
    let isNew: Bool

    private let iconOptions = [
        "folder", "folder.fill", "book.closed", "book",
        "tray.full", "archivebox", "briefcase", "star",
        "heart", "lightbulb", "graduationcap", "globe",
        "paintbrush", "wrench", "house", "cart"
    ]

    private let colorOptions: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("purple", .purple),
        ("pink", .pink),
        ("red", .red),
        ("orange", .orange),
        ("green", .green),
        ("teal", .teal),
        ("indigo", .indigo)
    ]

    var body: some View {
        Form {
            Section("Name") {
                TextField("Notebook name", text: $notebook.name)
            }

            Section("Icon") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                    ForEach(iconOptions, id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(notebook.iconName == icon ? colorForName(notebook.colorName) : .secondary)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(notebook.iconName == icon ? colorForName(notebook.colorName).opacity(0.15) : Color.clear)
                            )
                            .onTapGesture {
                                notebook.iconName = icon
                            }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Color") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(colorOptions, id: \.name) { item in
                            Circle()
                                .fill(item.color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: notebook.colorName == item.name ? 2 : 0)
                                        .padding(-2)
                                )
                                .onTapGesture {
                                    notebook.colorName = item.name
                                }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(isNew ? "New Notebook" : "Edit Notebook")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isNew ? "Create" : "Save") {
                    if isNew {
                        notebookStore.addNotebook(notebook)
                    } else {
                        notebookStore.updateNotebook(notebook)
                    }
                    dismiss()
                }
                .disabled(notebook.name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func colorForName(_ name: String) -> Color {
        colorOptions.first { $0.name == name }?.color ?? .blue
    }
}

#Preview {
    NavigationStack {
        NotebookEditorView(notebook: Notebook(), isNew: true)
            .environmentObject(NotebookStore())
    }
}
