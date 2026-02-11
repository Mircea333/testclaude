import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var userProfileStore: UserProfileStore
    @EnvironmentObject var noteStore: NoteStore
    @State private var showingClearAlert = false
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var importError: String?
    @State private var showingImportError = false

    private let accentColors: [(name: String, color: Color)] = [
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
            // Account Section
            Section("Account") {
                NavigationLink(destination: ProfileView()) {
                    HStack(spacing: 12) {
                        Image(systemName: userProfileStore.profile?.avatarSystemName ?? "person.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.accentColor)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(userProfileStore.profile?.name ?? "Guest")
                                .font(.headline)
                            Text(userProfileStore.profile?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Appearance Section
            Section("Appearance") {
                Picker("Theme", selection: $settingsStore.settings.appearanceMode) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Label(mode.label, systemImage: mode.iconName)
                            .tag(mode)
                    }
                }

                Picker("Font Size", selection: $settingsStore.settings.fontSize) {
                    ForEach(FontSizePreference.allCases, id: \.self) { size in
                        Text(size.label).tag(size)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Accent Color")
                        .font(.subheadline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(accentColors, id: \.name) { item in
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: settingsStore.settings.accentColorName == item.name ? 2 : 0)
                                            .padding(-2)
                                    )
                                    .onTapGesture {
                                        settingsStore.settings.accentColorName = item.name
                                        settingsStore.save()
                                    }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // Note Defaults Section
            Section("Note Defaults") {
                Picker("Default Priority", selection: $settingsStore.settings.defaultPriority) {
                    ForEach(NotePriority.allCases, id: \.self) { priority in
                        Text(priority.label).tag(priority)
                    }
                }

                Picker("Default Sort Order", selection: $settingsStore.settings.defaultSortOrder) {
                    ForEach(NoteSortOrder.allCases, id: \.self) { order in
                        Text(order.label).tag(order)
                    }
                }

                Picker("Default View Mode", selection: $settingsStore.settings.defaultViewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Label(mode == .list ? "List" : "Grid", systemImage: mode.iconName)
                            .tag(mode)
                    }
                }
            }

            // Notifications Section
            Section("Notifications & Reminders") {
                Toggle("Enable Notifications", isOn: $settingsStore.settings.notificationsEnabled)

                if settingsStore.settings.notificationsEnabled {
                    HStack {
                        Text("Default Reminder Time")
                        Spacer()
                        Text(String(format: "%02d:%02d",
                                    settingsStore.settings.defaultReminderHour,
                                    settingsStore.settings.defaultReminderMinute))
                            .foregroundColor(.secondary)
                    }

                    Toggle("Reminder Sound", isOn: $settingsStore.settings.reminderSoundEnabled)
                }
            }

            // Data Management Section
            Section("Data Management") {
                Button {
                    showingExportSheet = true
                } label: {
                    Label("Export Notes", systemImage: "square.and.arrow.up")
                }

                Button {
                    showingImportPicker = true
                } label: {
                    Label("Import Notes", systemImage: "square.and.arrow.down")
                }

                let info = settingsStore.storageInfo()
                LabeledContent("Notes Storage") {
                    Text(ByteCountFormatter.string(fromByteCount: info.noteFileSize, countStyle: .file))
                        .foregroundColor(.secondary)
                }

                LabeledContent("Settings Storage") {
                    Text(ByteCountFormatter.string(fromByteCount: info.settingsFileSize, countStyle: .file))
                        .foregroundColor(.secondary)
                }

                Button("Clear All Data", role: .destructive) {
                    showingClearAlert = true
                }
            }

            // About Section
            Section("About") {
                LabeledContent("Version") {
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }

                Button("Reset Settings to Defaults") {
                    settingsStore.resetToDefaults()
                }
            }
        }
        .navigationTitle("Settings")
        .onChange(of: settingsStore.settings) { _ in
            settingsStore.save()
        }
        .alert("Clear All Data", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                noteStore.clearAllNotes()
            }
        } message: {
            Text("This will permanently delete all your notes. This action cannot be undone.")
        }
        .sheet(isPresented: $showingExportSheet) {
            if let data = noteStore.exportNotesData(),
               let url = saveExportToTempFile(data: data) {
                ShareSheet(activityItems: [url])
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [UTType.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .alert("Import Error", isPresented: $showingImportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importError ?? "An unknown error occurred.")
        }
    }

    private func saveExportToTempFile(data: Data) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SwiftNotes_Export.json")
        try? data.write(to: tempURL)
        return tempURL
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else {
                importError = "Unable to access the selected file."
                showingImportError = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let data = try Data(contentsOf: url)
                try noteStore.importNotes(from: data)
            } catch {
                importError = "Failed to import notes: \(error.localizedDescription)"
                showingImportError = true
            }
        case .failure(let error):
            importError = "Failed to select file: \(error.localizedDescription)"
            showingImportError = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(SettingsStore())
            .environmentObject(UserProfileStore())
            .environmentObject(NoteStore())
    }
}
