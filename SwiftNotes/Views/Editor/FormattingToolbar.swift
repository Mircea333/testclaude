import SwiftUI

struct FormattingToolbar: View {
    @Binding var blocks: [NoteBlock]
    @Binding var focusedBlockIndex: Int?
    let onPickImage: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                // Text formatting
                Group {
                    toolbarButton("B", font: .body.bold(), isActive: currentFormatting?.isBold ?? false) {
                        toggleBold()
                    }

                    toolbarButton("I", font: .body.italic(), isActive: currentFormatting?.isItalic ?? false) {
                        toggleItalic()
                    }

                    toolbarButton("U", font: .body, isActive: currentFormatting?.isUnderline ?? false, underlined: true) {
                        toggleUnderline()
                    }
                }

                Divider()
                    .frame(height: 24)
                    .padding(.horizontal, 4)

                // Block type buttons
                Group {
                    iconButton("text.justify.left", tooltip: "Text", isActive: currentBlockType == .text) {
                        setBlockType(.text)
                    }

                    iconButton("textformat.size.larger", tooltip: "Heading", isActive: currentBlockType == .heading) {
                        setBlockType(.heading)
                    }

                    iconButton("list.bullet", tooltip: "Bullet", isActive: currentBlockType == .bulletList) {
                        setBlockType(.bulletList)
                    }

                    iconButton("list.number", tooltip: "Numbered", isActive: currentBlockType == .numberedList) {
                        setBlockType(.numberedList)
                    }

                    iconButton("checklist", tooltip: "Checklist", isActive: currentBlockType == .checklist) {
                        setBlockType(.checklist)
                    }
                }

                Divider()
                    .frame(height: 24)
                    .padding(.horizontal, 4)

                // Insert buttons
                Group {
                    iconButton("photo", tooltip: "Image") {
                        onPickImage()
                    }

                    iconButton("minus", tooltip: "Divider") {
                        insertDivider()
                    }

                    iconButton("plus", tooltip: "New Block") {
                        addNewBlock()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Current Block State

    private var currentFormatting: TextFormatting? {
        guard let index = focusedBlockIndex, index < blocks.count else { return nil }
        return blocks[index].formatting
    }

    private var currentBlockType: NoteBlockType? {
        guard let index = focusedBlockIndex, index < blocks.count else { return nil }
        return blocks[index].type
    }

    // MARK: - Formatting Actions

    private func toggleBold() {
        guard let index = focusedBlockIndex, index < blocks.count else { return }
        blocks[index].formatting.isBold.toggle()
    }

    private func toggleItalic() {
        guard let index = focusedBlockIndex, index < blocks.count else { return }
        blocks[index].formatting.isItalic.toggle()
    }

    private func toggleUnderline() {
        guard let index = focusedBlockIndex, index < blocks.count else { return }
        blocks[index].formatting.isUnderline.toggle()
    }

    private func setBlockType(_ type: NoteBlockType) {
        guard let index = focusedBlockIndex, index < blocks.count else { return }
        blocks[index].type = type
    }

    private func insertDivider() {
        let newBlock = NoteBlock(type: .divider)
        let insertIndex = (focusedBlockIndex ?? blocks.count - 1) + 1
        blocks.insert(newBlock, at: min(insertIndex, blocks.count))
    }

    private func addNewBlock() {
        let newBlock = NoteBlock(type: .text)
        let insertIndex = (focusedBlockIndex ?? blocks.count - 1) + 1
        blocks.insert(newBlock, at: min(insertIndex, blocks.count))
    }

    // MARK: - Button Views

    private func toolbarButton(_ text: String, font: Font, isActive: Bool, underlined: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(font)
                .underline(underlined)
                .frame(width: 32, height: 32)
                .background(isActive ? Color.accentColor.opacity(0.15) : Color.clear)
                .foregroundColor(isActive ? .accentColor : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private func iconButton(_ systemName: String, tooltip: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.subheadline)
                .frame(width: 32, height: 32)
                .background(isActive ? Color.accentColor.opacity(0.15) : Color.clear)
                .foregroundColor(isActive ? .accentColor : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FormattingToolbar(
        blocks: .constant([NoteBlock(type: .text, text: "Hello")]),
        focusedBlockIndex: .constant(0),
        onPickImage: {}
    )
}
