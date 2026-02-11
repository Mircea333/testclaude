import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.title.bold())
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(width: 120, height: 100)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HStack {
        StatCardView(title: "Total Notes", value: "42", iconName: "note.text", color: .blue)
        StatCardView(title: "This Week", value: "7", iconName: "calendar", color: .green)
        StatCardView(title: "Flagged", value: "3", iconName: "flag.fill", color: .orange)
    }
    .padding()
}
