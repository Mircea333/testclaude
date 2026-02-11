import Foundation
import UIKit

class ImageStore {
    static let shared = ImageStore()

    private let imagesDirectory: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDir = documentsDirectory.appendingPathComponent("NoteImages")
        if !FileManager.default.fileExists(atPath: imagesDir.path) {
            try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        return imagesDir
    }()

    private init() {}

    func saveImage(_ image: UIImage, noteID: UUID) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileName = "\(noteID.uuidString)_\(UUID().uuidString).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL, options: .atomic)
            return fileName
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
            return nil
        }
    }

    func loadImage(fileName: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    func deleteImage(fileName: String) {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }

    func deleteImages(for noteID: UUID) {
        let prefix = noteID.uuidString
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: imagesDirectory.path) else { return }
        for file in files where file.hasPrefix(prefix) {
            let fileURL = imagesDirectory.appendingPathComponent(file)
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}
