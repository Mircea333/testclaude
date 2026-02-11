import SwiftUI

struct TagPickerView: View {
    @EnvironmentObject var notebookStore: NotebookStore
    @Binding var selectedTagIDs: [UUID]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            if notebookStore.tags.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tag")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No Tags Available")
                        .font(.headline)
                    Text("Create tags in the Tag Manager first.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .listRowSeparator(.hidden)
            } else {
                ForEach(notebookStore.tags) { tag in
                    Button {
                        toggleTag(tag.id)
                    } label: {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(tag.color)
                                .frame(width: 12, height: 12)

                            Text(tag.name)
                                .foregroundColor(.primary)

                            Spacer()

                            if selectedTagIDs.contains(tag.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Tags")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private func toggleTag(_ id: UUID) {
        if let index = selectedTagIDs.firstIndex(of: id) {
            selectedTagIDs.remove(at: index)
        } else {
            selectedTagIDs.append(id)
        }
    }
}

#Preview {
    NavigationStack {
        TagPickerView(selectedTagIDs: .constant([]))
            .environmentObject(NotebookStore())
    }
}
