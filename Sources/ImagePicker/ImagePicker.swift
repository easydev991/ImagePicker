import SwiftUI
import PhotosUI

public struct ImagePicker: UIViewControllerRepresentable {
    @Binding private var pickedImages: [UIImage]
    @Binding private var isPresented: Bool
    /// The maximum number of assets that can be selected. Default is 1.
    ///
    /// Setting `selectionLimit` to 0 means maximum supported by the system.
    private var selectionLimit = 1
    /// The quality of the resulting JPEG image, expressed as a value from `0.0` to `1.0`.
    ///
    /// - The value `0.0` represents the maximum compression (or lowest quality) while the value `1.0` represents the least compression (or best quality).
    /// - If not specified, no compression will be applied.
    private let compressionQuality: CGFloat?

    public init(
        pickedImages: Binding<[UIImage]>,
        isPresented: Binding<Bool>,
        selectionLimit: Int = 1,
        compressionQuality: CGFloat? = nil
    ) {
        self._pickedImages = pickedImages
        self._isPresented = isPresented
        self.selectionLimit = selectionLimit
        self.compressionQuality = compressionQuality
    }

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
                        let finalImage: UIImage
                        if let compressionQuality = self?.parent.compressionQuality,
                           let compressedData = image.jpegData(compressionQuality: compressionQuality),
                           let compressedImage = UIImage(data: compressedData) {
                            finalImage = compressedImage
                        } else {
                            finalImage = image
                        }
                        queue.async(flags: .barrier) {
                            self?.parent.pickedImages.append(finalImage)
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
