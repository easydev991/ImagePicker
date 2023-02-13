import ImagePicker
import SwiftUI

struct ContentView: View {
    @State private var pickedImages = [UIImage]()
    @State private var showPicker = false

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                deleteImagesButton
                Spacer()
                showImagePickerButton
            }
            contentBody
                .animation(.default, value: isListEmpty)
                .sheet(isPresented: $showPicker) {
                    ImagePicker(
                        pickedImages: $pickedImages,
                        selectionLimit: 5
                    )
                }
        }
        .padding()
    }
}

private extension ContentView {
    @ViewBuilder
    var contentBody: some View {
        if isListEmpty {
            Button("Pick Images") { showPicker.toggle() }
        } else {
            List {
                ForEach(photosTuple, id: \.0) { index, uiImage in
                    HStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .cornerRadius(12)
                            .aspectRatio(contentMode: .fit)
                        VStack(spacing: 8) {
                            Text("Image # \(index + 1)")
                                .bold()
                            Text("Swipe to delete")
                                .foregroundColor(.red)
                        }
                        .padding()
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
        }
    }

    var deleteImagesButton: some View {
        Button {
            withAnimation { pickedImages.removeAll() }
        } label: {
            Image(systemName: "trash.circle.fill")
                .font(.title)
                .foregroundColor(.red)
        }
        .opacity(isListEmpty ? 0 : 1)
    }

    var showImagePickerButton: some View {
        Button {
            showPicker.toggle()
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title)
        }
        .opacity(isListEmpty ? 0 : 1)
    }

    var photosTuple: [(Int, UIImage)] {
        .init(zip(pickedImages.indices, pickedImages))
    }

    var isListEmpty: Bool { pickedImages.isEmpty }

    func delete(at offsets: IndexSet) {
        withAnimation { pickedImages.remove(atOffsets: offsets) }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
