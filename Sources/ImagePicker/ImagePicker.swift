import SwiftUI
import PhotosUI

public struct ImagePicker: UIViewControllerRepresentable {
    @Binding public var pickedImages: [UIImage]
    @Binding public var isPresented: Bool
    /// The maximum number of assets that can be selected. Default is 1.
    ///
    /// Setting `selectionLimit` to 0 means maximum supported by the system.
    public var selectionLimit = 1

    public func makeUIViewController(context: Context) -> some UIViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = selectionLimit

        let photoPickerViewController = PHPickerViewController(configuration: configuration)
        photoPickerViewController.delegate = context.coordinator
        return photoPickerViewController
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        .init(self)
    }

    final public class Coordinator: PHPickerViewControllerDelegate {
        private let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let queue = DispatchQueue(label: "ImagePickerConcurrentQueue", qos: .userInteractive, attributes: .concurrent)
            let group = DispatchGroup()
            for image in results {
                guard image.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
                group.enter()
                image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] newImage, _ in
                    if let image = newImage as? UIImage {
                        queue.async(flags: .barrier) {
                            self?.parent.pickedImages.append(image)
                        }
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) { [weak self] in
                self?.parent.isPresented = false
            }
        }
    }
}
