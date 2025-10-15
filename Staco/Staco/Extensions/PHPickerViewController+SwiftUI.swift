import PhotosUI
import SwiftUI

extension PHPickerViewController {
    struct PHPickerView: UIViewControllerRepresentable {
        let selectionLimit: Int
        let onSelect: ([UIImage]) -> Void
        
        func makeUIViewController(context: Context) -> PHPickerViewController {
            var config = PHPickerConfiguration()
            config.selectionLimit = selectionLimit
            config.filter = .images
            
            let controller = PHPickerViewController(configuration: config)
            controller.delegate = context.coordinator
            return controller
        }
        
        func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, PHPickerViewControllerDelegate {
            let parent: PHPickerView
            
            init(_ parent: PHPickerView) {
                self.parent = parent
            }
            
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                picker.dismiss(animated: true)
                
                let dispatchGroup = DispatchGroup()
                var images = [UIImage]()
                
                for result in results {
                    dispatchGroup.enter()
                    
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                            defer { dispatchGroup.leave() }
                            
                            if let image = image as? UIImage {
                                images.append(image)
                            }
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.parent.onSelect(images)
                }
            }
        }
    }
}
