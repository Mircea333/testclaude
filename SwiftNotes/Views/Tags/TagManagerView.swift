import SwiftUI

struct TagManagerView: View {
    @EnvironmentObject var notebookStore: NotebookStore
    @State private var newTagName = ""
    @State private var newTagColor = "blue"
    @State private var editingTag: Tag?
    @State private var editTagName = ""
    @State private var editTagColor = ""

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
        List {
            // Add new tag section
            Section("Add Tag") {
                HStack(spacing: 8) {
                    TextField("Tag name", text: $newTagName)

                    Menu {
                        ForEach(colorOptions, id: \.name) { item in
                            Button {
                                newTagColor = item.name
                            } label: {
                                HStack {
                                    Text(item.name.capitalized)
                                    if newTagColor == item.name {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Circle()
                            .fill(colorForName(newTagColor))
                            .frame(width: 24, height: 24)
                    }

                    Button {
                        let tag = Tag(name: newTagName.trimmingCharacters(in: .whitespaces), colorName: newTagColor)
                        notebookStore.addTag(tag)
                        newTagName = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            // Existing tags
            Section("Tags") {
                if notebookStore.tags.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tag")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("No Tags")
                            .font(.headline)
                        Text("Add a tag above to get started.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(notebookStore.tags) { tag in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(tag.color)
                                .frame(width: 12, height: 12)

                            if editingTag?.id == tag.id {
                                TextField("Tag name", text: $editTagName)
                                    .textFieldStyle(.roundedBorder)

                                Menu {
                                    ForEach(colorOptions, id: \.name) { item in
                                        Button {
                                            editTagColor = item.name
                                        } label: {
                                            HStack {
                                                Text(item.name.capitalized)
                                                if editTagColor == item.name {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Circle()
                                        .fill(colorForName(editTagColor))
                                        .frame(width: 20, height: 20)
                                }

                                Button("Save") {
                                    var updated = tag
                                    updated.name = editTagName.trimmingCharacters(in: .whitespaces)
                                    updated.colorName = editTagColor
                                    notebookStore.updateTag(updated)
                                    editingTag = nil
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            } else {
                                Text(tag.name)
                                    .font(.body)

                                Spacer()
                            }
                        }
                        .contextMenu {
                            Button {
                                editingTag = tag
                                editTagName = tag.name
                                editTagColor = tag.colorName
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                notebookStore.deleteTag(tag)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                notebookStore.deleteTag(tag)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Tags")
    }

    private func colorForName(_ name: String) -> Color {
        colorOptions.first { $0.name == name }?.color ?? .blue
    }
}

#Preview {
    NavigationStack {
        TagManagerView()
            .environmentObject(NotebookStore())
    }
}
