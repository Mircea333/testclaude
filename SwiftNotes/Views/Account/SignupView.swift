import SwiftUI

struct SignupView: View {
    @EnvironmentObject var userProfileStore: UserProfileStore
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var showingError = false

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@")
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)

                Text("Create Account")
                    .font(.largeTitle.bold())

                Text("Get started with SwiftNotes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Form fields
            VStack(spacing: 16) {
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .autocorrectionDisabled()

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 32)

            // Create account button
            Button {
                if isFormValid {
                    userProfileStore.signUp(
                        name: name.trimmingCharacters(in: .whitespaces),
                        email: email.trimmingCharacters(in: .whitespaces)
                    )
                    dismiss()
                } else {
                    showingError = true
                }
            } label: {
                Text("Create Account")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isFormValid ? Color.accentColor : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
            .padding(.horizontal, 32)

            // Back to login
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                    Text("Log In")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }

            Spacer()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Invalid Input", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a valid name and email address.")
        }
    }
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(UserProfileStore())
    }
}
