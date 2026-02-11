import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userProfileStore: UserProfileStore
    @State private var isEditing = false
    @State private var editName: String = ""
    @State private var editEmail: String = ""
    @State private var editAvatar: String = "person.circle.fill"
    @State private var showingLogoutAlert = false

    private let avatarOptions = [
        "person.circle.fill",
        "person.crop.circle.fill",
        "face.smiling",
        "star.circle.fill",
        "heart.circle.fill",
        "bolt.circle.fill",
        "leaf.circle.fill",
        "flame.circle.fill"
    ]

    var body: some View {
        List {
            // Avatar and name section
            Section {
                VStack(spacing: 16) {
                    if isEditing {
                        avatarPicker
                    } else {
                        Image(systemName: userProfileStore.profile?.avatarSystemName ?? "person.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(.accentColor)
                    }

                    if isEditing {
                        TextField("Name", text: $editName)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)

                        TextField("Email", text: $editEmail)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    } else {
                        Text(userProfileStore.profile?.name ?? "")
                            .font(.title2.bold())

                        Text(userProfileStore.profile?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            // Member info
            if let profile = userProfileStore.profile {
                Section("Account Info") {
                    LabeledContent("Member Since") {
                        Text(profile.createdAt, style: .date)
                    }

                    LabeledContent("User ID") {
                        Text(profile.id.uuidString.prefix(8).lowercased())
                            .font(.caption.monospaced())
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Actions
            Section {
                Button(isEditing ? "Save Changes" : "Edit Profile") {
                    if isEditing {
                        saveChanges()
                    } else {
                        startEditing()
                    }
                }

                if isEditing {
                    Button("Cancel Editing") {
                        isEditing = false
                    }
                    .foregroundColor(.secondary)
                }
            }

            // Logout
            Section {
                Button("Log Out", role: .destructive) {
                    showingLogoutAlert = true
                }
            }
        }
        .navigationTitle("Profile")
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                userProfileStore.logOut()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }

    private var avatarPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(avatarOptions, id: \.self) { avatar in
                    Image(systemName: avatar)
                        .font(.system(size: 40))
                        .foregroundColor(editAvatar == avatar ? .accentColor : .secondary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(editAvatar == avatar ? Color.accentColor.opacity(0.15) : Color.clear)
                        )
                        .onTapGesture {
                            editAvatar = avatar
                        }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func startEditing() {
        editName = userProfileStore.profile?.name ?? ""
        editEmail = userProfileStore.profile?.email ?? ""
        editAvatar = userProfileStore.profile?.avatarSystemName ?? "person.circle.fill"
        isEditing = true
    }

    private func saveChanges() {
        guard var profile = userProfileStore.profile else { return }
        profile.name = editName.trimmingCharacters(in: .whitespaces)
        profile.email = editEmail.trimmingCharacters(in: .whitespaces)
        profile.avatarSystemName = editAvatar
        userProfileStore.updateProfile(profile)
        isEditing = false
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(UserProfileStore())
    }
}
