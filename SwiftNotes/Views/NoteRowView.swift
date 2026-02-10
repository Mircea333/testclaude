import SwiftUI

struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.headline)
                .lineLimit(1)

            HStack(spacing: 8) {
                Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(note.preview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        NoteRowView(note: Note(title: "Shopping List", content: "Eggs, milk, bread, butter"))
        NoteRowView(note: Note(title: "Meeting Notes", content: "Discussed Q4 planning and roadmap"))
    }
}
