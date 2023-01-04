import SwiftUI
import ImagePicker

struct SwiftUIView: View {
    @State private var pickedImages = [UIImage]()
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            List(pickedImages, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(contentMode: .fit)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(
                    pickedImages: $pickedImages,
                    selectionLimit: 5,
                    compressionQuality: .zero
                )
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        showImagePicker.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
