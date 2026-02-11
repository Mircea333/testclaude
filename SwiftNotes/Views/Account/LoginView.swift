import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userProfileStore: UserProfileStore
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var showingSignup = false
    @State private var showingError = false

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@")
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App icon and title
            VStack(spacing: 12) {
                Image(systemName: "note.text")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)

                Text("SwiftNotes")
                    .font(.largeTitle.bold())

                Text("Welcome back")
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

            // Log in button
            Button {
                if isFormValid {
                    userProfileStore.logIn(
                        name: name.trimmingCharacters(in: .whitespaces),
                        email: email.trimmingCharacters(in: .whitespaces)
                    )
                } else {
                    showingError = true
                }
            } label: {
                Text("Log In")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isFormValid ? Color.accentColor : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
            .padding(.horizontal, 32)

            // Sign up link
            Button {
                showingSignup = true
            } label: {
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    Text("Sign Up")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }

            Spacer()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSignup) {
            NavigationStack {
                SignupView()
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
        LoginView()
            .environmentObject(UserProfileStore())
    }
}
