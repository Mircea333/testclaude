import SwiftUI

struct NoteRowView: View {
    let note: Note

    var body: some View {
        HStack(spacing: 10) {
            if note.priority != .none {
                priorityIndicator
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(note.title.isEmpty ? "Untitled" : note.title)
                        .font(.headline)
                        .lineLimit(1)

                    if note.isFlagged {
                        Image(systemName: "flag.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    if note.hasReminder {
                        Image(systemName: note.isReminderOverdue ? "bell.badge.fill" : "bell.fill")
                            .font(.caption)
                            .foregroundColor(note.isReminderOverdue ? .red : .purple)
                    }
                }

                HStack(spacing: 8) {
                    Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if note.priority != .none {
                        Text(note.priority.label)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(priorityColor.opacity(0.15))
                            .foregroundColor(priorityColor)
                            .cornerRadius(3)
                    }

                    Text(note.preview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if let reminderDate = note.reminderDate {
                    HStack(spacing: 4) {
                        Image(systemName: "bell")
                            .font(.caption2)
                        Text(reminderDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                    }
                    .foregroundColor(note.isReminderOverdue ? .red : .purple)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var priorityIndicator: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(priorityColor)
            .frame(width: 4, height: 36)
    }

    private var priorityColor: Color {
        switch note.priority {
        case .none: return .secondary
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    List {
        NoteRowView(note: Note(title: "Shopping List", content: "Eggs, milk, bread, butter", priority: .high, isFlagged: true))
        NoteRowView(note: Note(title: "Meeting Notes", content: "Discussed Q4 planning and roadmap", priority: .medium, reminderDate: Date().addingTimeInterval(3600)))
        NoteRowView(note: Note(title: "Ideas", content: "Some quick ideas for the project", priority: .low))
        NoteRowView(note: Note(title: "Plain Note", content: "Just a regular note"))
    }
}
