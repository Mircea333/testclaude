import SwiftUI

struct RichTextEditorView: View {
    @Binding var blocks: [NoteBlock]
    @FocusState private var focusedBlockID: UUID?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach($blocks) { $block in
                    blockView(for: $block)
                        .focused($focusedBlockID, equals: block.id)
                }
            }
            .padding(.horizontal, 12)
        }
    }

    @ViewBuilder
    private func blockView(for block: Binding<NoteBlock>) -> some View {
        switch block.wrappedValue.type {
        case .text, .heading:
            textBlockView(block: block)

        case .bulletList:
            HStack(alignment: .top, spacing: 8) {
                Text("\u{2022}")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                TextField("", text: block.text, axis: .vertical)
                    .font(fontForBlock(block.wrappedValue))
                    .lineLimit(nil)
            }

        case .numberedList:
            HStack(alignment: .top, spacing: 8) {
                Text("\(block.wrappedValue.listIndex ?? 1).")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: 24, alignment: .trailing)
                    .padding(.top, 8)
                TextField("", text: block.text, axis: .vertical)
                    .font(fontForBlock(block.wrappedValue))
                    .lineLimit(nil)
            }

        case .checklist:
            HStack(alignment: .top, spacing: 8) {
                Button {
                    block.wrappedValue.isChecked.toggle()
                } label: {
                    Image(systemName: block.wrappedValue.isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(block.wrappedValue.isChecked ? .green : .secondary)
                }
                .buttonStyle(.plain)
                .padding(.top, 6)

                TextField("", text: block.text, axis: .vertical)
                    .font(.body)
                    .strikethrough(block.wrappedValue.isChecked)
                    .foregroundColor(block.wrappedValue.isChecked ? .secondary : .primary)
                    .lineLimit(nil)
            }

        case .image:
            if let fileName = block.wrappedValue.imageFileName,
               let uiImage = ImageStore.shared.loadImage(fileName: fileName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
                    .frame(maxHeight: 300)
                    .padding(.vertical, 4)
            } else {
                HStack {
                    Image(systemName: "photo")
                        .foregroundColor(.secondary)
                    Text("Image not found")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.vertical, 8)
            }

        case .divider:
            Divider()
                .padding(.vertical, 8)
        }
    }

    private func textBlockView(block: Binding<NoteBlock>) -> some View {
        TextField("", text: block.text, axis: .vertical)
            .font(fontForBlock(block.wrappedValue))
            .bold(block.wrappedValue.formatting.isBold)
            .italic(block.wrappedValue.formatting.isItalic)
            .underline(block.wrappedValue.formatting.isUnderline)
            .lineLimit(nil)
    }

    private func fontForBlock(_ block: NoteBlock) -> Font {
        switch block.type {
        case .heading: return .title2.bold()
        default: return .body
        }
    }
}

#Preview {
    RichTextEditorView(blocks: .constant([
        NoteBlock(type: .heading, text: "My Note"),
        NoteBlock(type: .text, text: "This is a paragraph of text."),
        NoteBlock(type: .bulletList, text: "First item"),
        NoteBlock(type: .bulletList, text: "Second item"),
        NoteBlock(type: .checklist, text: "Task one", isChecked: true),
        NoteBlock(type: .checklist, text: "Task two", isChecked: false),
        NoteBlock(type: .divider),
        NoteBlock(type: .numberedList, text: "Step one", listIndex: 1),
        NoteBlock(type: .numberedList, text: "Step two", listIndex: 2)
    ]))
}
