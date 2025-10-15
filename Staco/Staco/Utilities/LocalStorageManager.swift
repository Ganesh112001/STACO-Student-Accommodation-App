import UIKit

class LocalStorageManager {
    static let shared = LocalStorageManager()
    
    private init() {}
    
    // Get document directory path
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Save image to documents directory with unique name
    func saveImage(_ image: UIImage, withName name: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        
        let filename = "\(name)_\(UUID().uuidString).jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return filename  // Return just the filename for storage
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Load image from documents directory by name
    func loadImage(name: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(name)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Delete image from documents directory
    func deleteImage(name: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(name)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error deleting image: \(error.localizedDescription)")
        }
    }
}
