# ImagePicker

A PHPickerViewController wrapped in a UIViewControllerRepresentable to be used in SwiftUI views to pick images from PhotoLibrary.

Currently PHPickerViewController has a bug: it allows picking multiple items by tapping multiple times very quickly (even the same item) before the picker disappears, even with selectionLimit set to 1.
