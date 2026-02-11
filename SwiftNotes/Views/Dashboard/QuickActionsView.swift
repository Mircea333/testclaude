import SwiftUI

struct QuickActionsView: View {
    let onNewNote: () -> Void
    let onNewChecklist: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            quickActionButton(
                title: "New Note",
                icon: "square.and.pencil",
                color: .accentColor,
                action: onNewNote
            )

            quickActionButton(
                title: "New Checklist",
                icon: "checklist",
                color: .green,
                action: onNewChecklist
            )
        }
    }

    private func quickActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .cornerRadius(10)
        }
    }
}

#Preview {
    QuickActionsView(onNewNote: {}, onNewChecklist: {})
        .padding()
}
