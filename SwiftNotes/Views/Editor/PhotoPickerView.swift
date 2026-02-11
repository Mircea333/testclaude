import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .padding()

                Button("Use This Image") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .padding(.top, 40)

                Text("Select a Photo")
                    .font(.title2.bold())

                Text("Choose an image from your photo library to add to your note.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label(selectedImage == nil ? "Choose Photo" : "Change Photo", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .navigationTitle("Add Image")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    selectedImage = nil
                    dismiss()
                }
            }
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhotoPickerView(selectedImage: .constant(nil))
    }
}
