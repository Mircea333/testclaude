import SwiftUI

struct SidebarMenuView: View {
    @EnvironmentObject var noteStore: NoteStore
    @EnvironmentObject var notebookStore: NotebookStore
    @EnvironmentObject var userProfileStore: UserProfileStore
    @Environment(\.dismiss) private var dismiss

    let onSelectAllNotes: () -> Void
    let onSelectNotebook: (UUID) -> Void

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                if let profile = userProfileStore.profile {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: profile.avatarSystemName)
                                .font(.system(size: 36))
                                .foregroundColor(.accentColor)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(profile.name)
                                    .font(.headline)
                                Text(profile.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Notes Section
                Section("Notes") {
                    Button {
                        onSelectAllNotes()
                        dismiss()
                    } label: {
                        Label {
                            HStack {
                                Text("All Notes")
                                Spacer()
                                Text("\(noteStore.activeNotes.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.tertiarySystemFill))
                                    .cornerRadius(10)
                            }
                        } icon: {
                            Image(systemName: "note.text")
                        }
                    }
                    .foregroundColor(.primary)
                }

                // Notebooks Section
                if !notebookStore.notebooks.isEmpty {
                    Section("Notebooks") {
                        ForEach(notebookStore.notebooks) { notebook in
                            Button {
                                onSelectNotebook(notebook.id)
                                dismiss()
                            } label: {
                                Label {
                                    HStack {
                                        Text(notebook.name)
                                        Spacer()
                                        Text("\(noteStore.notesInNotebook(notebook.id).count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color(.tertiarySystemFill))
                                            .cornerRadius(10)
                                    }
                                } icon: {
                                    Image(systemName: notebook.iconName)
                                        .foregroundColor(colorForName(notebook.colorName))
                                }
                            }
                            .foregroundColor(.primary)
                        }

                        NavigationLink(destination: NotebookListView()) {
                            Label("Manage Notebooks", systemImage: "folder.badge.gearshape")
                                .foregroundColor(.accentColor)
                        }
                    }
                }

                // Tags Section
                if !notebookStore.tags.isEmpty {
                    Section("Tags") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(notebookStore.tags) { tag in
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(tag.color)
                                            .frame(width: 8, height: 8)
                                        Text(tag.name)
                                            .font(.caption)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(tag.color.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                        NavigationLink(destination: TagManagerView()) {
                            Label("Manage Tags", systemImage: "tag.circle")
                                .foregroundColor(.accentColor)
                        }
                    }
                }

                // Archive & Trash Section
                Section {
                    NavigationLink(destination: DashboardView()) {
                        Label {
                            Text("Dashboard")
                        } icon: {
                            Image(systemName: "chart.bar")
                        }
                    }

                    NavigationLink(destination: ArchiveView()) {
                        Label {
                            HStack {
                                Text("Archive")
                                Spacer()
                                if noteStore.archivedNotes.count > 0 {
                                    Text("\(noteStore.archivedNotes.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color(.tertiarySystemFill))
                                        .cornerRadius(10)
                                }
                            }
                        } icon: {
                            Image(systemName: "archivebox")
                        }
                    }

                    NavigationLink(destination: TrashView()) {
                        Label {
                            HStack {
                                Text("Trash")
                                Spacer()
                                if noteStore.trashedNotes.count > 0 {
                                    Text("\(noteStore.trashedNotes.count)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                        } icon: {
                            Image(systemName: "trash")
                        }
                    }
                }

                // Settings Section
                Section {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape")
                    }

                    if notebookStore.notebooks.isEmpty {
                        NavigationLink(destination: NotebookListView()) {
                            Label("Manage Notebooks", systemImage: "folder.badge.gearshape")
                        }
                    }

                    if notebookStore.tags.isEmpty {
                        NavigationLink(destination: TagManagerView()) {
                            Label("Manage Tags", systemImage: "tag")
                        }
                    }
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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
    SidebarMenuView(
        onSelectAllNotes: {},
        onSelectNotebook: { _ in }
    )
    .environmentObject(NoteStore())
    .environmentObject(NotebookStore())
    .environmentObject(UserProfileStore())
}
