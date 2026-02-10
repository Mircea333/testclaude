import SwiftUI

struct NoteGridItemView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.headline)
                    .lineLimit(2)

                Spacer()

                if note.isFlagged {
                    Image(systemName: "flag.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            Text(note.preview)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)

            Spacer()

            HStack(spacing: 6) {
                if note.priority != .none {
                    priorityBadge
                }

                if note.hasReminder {
                    reminderBadge
                }

                Spacer()

                Text(note.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(minHeight: 120)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityBorderColor, lineWidth: note.priority == .high ? 2 : 0)
        )
    }

    private var priorityBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: note.priority.iconName)
                .font(.caption2)
            Text(note.priority.label)
                .font(.caption2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(priorityColor.opacity(0.15))
        .foregroundColor(priorityColor)
        .cornerRadius(4)
    }

    private var reminderBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: note.isReminderOverdue ? "bell.badge" : "bell")
                .font(.caption2)
            if let date = note.reminderDate {
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(note.isReminderOverdue ? Color.red.opacity(0.15) : Color.purple.opacity(0.15))
        .foregroundColor(note.isReminderOverdue ? .red : .purple)
        .cornerRadius(4)
    }

    private var priorityColor: Color {
        switch note.priority {
        case .none: return .secondary
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }

    private var priorityBorderColor: Color {
        switch note.priority {
        case .high: return .red.opacity(0.5)
        default: return .clear
        }
    }
}

#Preview {
    let sampleNotes = [
        Note(title: "Shopping List", content: "Eggs, milk, bread", priority: .high, isFlagged: true),
        Note(title: "Meeting Notes", content: "Discussed Q4 planning", priority: .medium, reminderDate: Date().addingTimeInterval(3600)),
        Note(title: "Ideas", content: "App redesign thoughts", priority: .low),
        Note(title: "Quick Note", content: "Remember to call back")
    ]

    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(sampleNotes) { note in
                NoteGridItemView(note: note)
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
