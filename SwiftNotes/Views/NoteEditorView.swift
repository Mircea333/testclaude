import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject var noteStore: NoteStore
    @EnvironmentObject var notebookStore: NotebookStore
    @Environment(\.dismiss) private var dismiss

    @State var note: Note
    let isNew: Bool

    @State private var showingDeleteAlert = false
    @State private var showingReminderPicker = false
    @State private var showingMetadata = false
    @State private var showingTagPicker = false
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Metadata bar
            metadataBar

            TextField("Title", text: $note.title)
                .font(.title2.bold())
                .padding(.horizontal)
                .padding(.top, 12)
                .focused($isTitleFocused)

            Divider()
                .padding(.horizontal)
                .padding(.vertical, 8)

            TextEditor(text: $note.content)
                .font(.body)
                .padding(.horizontal, 12)
                .scrollContentBackground(.hidden)
        }
        .navigationTitle(isNew ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNew {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .fontWeight(.semibold)
                    .disabled(note.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Flag toggle
                        Button {
                            note.isFlagged.toggle()
                        } label: {
                            Label(
                                note.isFlagged ? "Remove Flag" : "Flag Note",
                                systemImage: note.isFlagged ? "flag.slash" : "flag.fill"
                            )
                        }

                        // Priority submenu
                        Menu {
                            ForEach(NotePriority.allCases, id: \.self) { priority in
                                Button {
                                    note.priority = priority
                                } label: {
                                    HStack {
                                        if priority != .none {
                                            Image(systemName: priority.iconName)
                                        }
                                        Text(priority.label)
                                        if note.priority == priority {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Label("Priority", systemImage: "exclamationmark.3")
                        }

                        // Reminder
                        Button {
                            showingReminderPicker = true
                        } label: {
                            Label(
                                note.hasReminder ? "Edit Reminder" : "Add Reminder",
                                systemImage: "bell"
                            )
                        }

                        if note.hasReminder {
                            Button {
                                note.reminderDate = nil
                            } label: {
                                Label("Remove Reminder", systemImage: "bell.slash")
                            }
                        }

                        Divider()

                        // Show info
                        Button {
                            showingMetadata = true
                        } label: {
                            Label("Note Info", systemImage: "info.circle")
                        }

                        Divider()

                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Note", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            if isNew {
                isTitleFocused = true
            }
        }
        .onDisappear {
            if !isNew {
                saveExistingNote()
            }
        }
        .alert("Move to Trash", isPresented: $showingDeleteAlert) {
            Button("Move to Trash", role: .destructive) {
                noteStore.delete(note)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This note will be moved to trash. You can restore it within 30 days.")
        }
        .sheet(isPresented: $showingReminderPicker) {
            reminderPickerSheet
        }
        .sheet(isPresented: $showingMetadata) {
            noteInfoSheet
        }
        .sheet(isPresented: $showingTagPicker) {
            NavigationStack {
                TagPickerView(selectedTagIDs: $note.tagIDs)
            }
        }
    }

    // MARK: - Metadata Bar

    private var metadataBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Flag chip
                Button {
                    note.isFlagged.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: note.isFlagged ? "flag.fill" : "flag")
                            .font(.caption2)
                        Text(note.isFlagged ? "Flagged" : "Flag")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(note.isFlagged ? Color.orange.opacity(0.15) : Color(.tertiarySystemFill))
                    .foregroundColor(note.isFlagged ? .orange : .secondary)
                    .cornerRadius(14)
                }

                // Priority picker
                Menu {
                    ForEach(NotePriority.allCases, id: \.self) { priority in
                        Button {
                            note.priority = priority
                        } label: {
                            HStack {
                                if priority != .none {
                                    Image(systemName: priority.iconName)
                                }
                                Text(priority.label)
                                if note.priority == priority {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        if note.priority != .none {
                            Image(systemName: note.priority.iconName)
                                .font(.caption2)
                        }
                        Text(note.priority == .none ? "Priority" : note.priority.label)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(note.priority != .none ? priorityColor.opacity(0.15) : Color(.tertiarySystemFill))
                    .foregroundColor(note.priority != .none ? priorityColor : .secondary)
                    .cornerRadius(14)
                }

                // Reminder chip
                Button {
                    showingReminderPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: note.hasReminder ? "bell.fill" : "bell")
                            .font(.caption2)
                        if let date = note.reminderDate {
                            Text(date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .fontWeight(.medium)
                        } else {
                            Text("Reminder")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(note.hasReminder ? Color.purple.opacity(0.15) : Color(.tertiarySystemFill))
                    .foregroundColor(note.hasReminder ? .purple : .secondary)
                    .cornerRadius(14)
                }

                // Notebook picker chip
                Menu {
                    Button {
                        note.notebookID = nil
                    } label: {
                        HStack {
                            Text("None")
                            if note.notebookID == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    ForEach(notebookStore.notebooks) { notebook in
                        Button {
                            note.notebookID = notebook.id
                        } label: {
                            HStack {
                                Image(systemName: notebook.iconName)
                                Text(notebook.name)
                                if note.notebookID == notebook.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "folder")
                            .font(.caption2)
                        Text(notebookName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(note.notebookID != nil ? Color.teal.opacity(0.15) : Color(.tertiarySystemFill))
                    .foregroundColor(note.notebookID != nil ? .teal : .secondary)
                    .cornerRadius(14)
                }

                // Tags chip
                Button {
                    showingTagPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "tag")
                            .font(.caption2)
                        Text(note.tagIDs.isEmpty ? "Tags" : "\(note.tagIDs.count) tags")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(!note.tagIDs.isEmpty ? Color.green.opacity(0.15) : Color(.tertiarySystemFill))
                    .foregroundColor(!note.tagIDs.isEmpty ? .green : .secondary)
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .background(Color(.systemGroupedBackground).opacity(0.5))
    }

    // MARK: - Reminder Picker Sheet

    private var reminderPickerSheet: some View {
        NavigationStack {
            ReminderPickerView(
                reminderDate: Binding(
                    get: { note.reminderDate ?? Date().addingTimeInterval(3600) },
                    set: { note.reminderDate = $0 }
                ),
                hasReminder: Binding(
                    get: { note.hasReminder },
                    set: { if !$0 { note.reminderDate = nil } }
                )
            )
        }
    }

    // MARK: - Note Info Sheet

    private var noteInfoSheet: some View {
        NavigationStack {
            List {
                Section("Details") {
                    LabeledContent("Created", value: note.createdAt.formatted(date: .long, time: .shortened))
                    LabeledContent("Modified", value: note.updatedAt.formatted(date: .long, time: .shortened))
                    LabeledContent("Characters", value: "\(note.content.count)")
                    LabeledContent("Words", value: "\(wordCount)")
                }
                Section("Properties") {
                    LabeledContent("Priority", value: note.priority.label)
                    LabeledContent("Flagged", value: note.isFlagged ? "Yes" : "No")
                    if let date = note.reminderDate {
                        LabeledContent("Reminder", value: date.formatted(date: .long, time: .shortened))
                    } else {
                        LabeledContent("Reminder", value: "None")
                    }
                }
            }
            .navigationTitle("Note Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingMetadata = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private var notebookName: String {
        if let id = note.notebookID,
           let notebook = notebookStore.notebooks.first(where: { $0.id == id }) {
            return notebook.name
        }
        return "Notebook"
    }

    private var wordCount: Int {
        note.content.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }

    private var priorityColor: Color {
        switch note.priority {
        case .none: return .secondary
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }

    private func saveNote() {
        let trimmedTitle = note.title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        note.title = trimmedTitle
        note.updatedAt = Date()
        noteStore.add(note)
        dismiss()
    }

    private func saveExistingNote() {
        note.updatedAt = Date()
        noteStore.update(note)
    }
}

// MARK: - Reminder Picker View

struct ReminderPickerView: View {
    @Binding var reminderDate: Date
    @Binding var hasReminder: Bool
    @Environment(\.dismiss) private var dismiss

    private let quickOptions: [(String, TimeInterval)] = [
        ("In 1 hour", 3600),
        ("In 3 hours", 10800),
        ("Tomorrow morning", 0), // handled specially
        ("In 1 week", 604800)
    ]

    var body: some View {
        List {
            Section("Quick Options") {
                ForEach(quickOptions, id: \.0) { option in
                    Button {
                        if option.0 == "Tomorrow morning" {
                            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                            reminderDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow)!
                        } else {
                            reminderDate = Date().addingTimeInterval(option.1)
                        }
                        dismiss()
                    } label: {
                        Text(option.0)
                    }
                }
            }

            Section("Custom") {
                DatePicker(
                    "Date & Time",
                    selection: $reminderDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
            }

            if hasReminder {
                Section {
                    Button(role: .destructive) {
                        hasReminder = false
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Remove Reminder")
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle("Set Reminder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Set") {
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NoteEditorView(
            note: Note(title: "Sample", content: "Hello world", priority: .medium, isFlagged: true),
            isNew: false
        )
        .environmentObject(NoteStore())
    }
}
