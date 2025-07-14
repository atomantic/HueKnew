import SwiftUI
import PhotosUI

struct PhotoColorPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pickerItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var selectedColor: ColorInfo?
    @State private var showingCamera = false

    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    SelectableImageView(image: image) { uiColor in
                        if let match = ColorDatabase.shared.getClosestColor(to: uiColor) {
                            selectedColor = match
                        }
                    }
                    .frame(maxHeight: 300)
                } else {
                    Spacer()
                    Text("Select or capture a photo to begin")
                        .foregroundColor(.secondary)
                    Spacer()
                }

                if let colorInfo = selectedColor {
                    VStack(spacing: 12) {
                        Rectangle()
                            .fill(Color(hex: colorInfo.hexValue))
                            .frame(width: 120, height: 120)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 2))
                        Text(colorInfo.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Identify Color")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Image(systemName: "photo")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera")
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $image, sourceType: .camera)
            }
            .onChange(of: pickerItem) { newItem in
                if let newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            image = uiImage
                        }
                    }
                }
            }
        }
    }
}

struct SelectableImageView: View {
    let image: UIImage
    var onColorSelected: (UIColor) -> Void

    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            let scaleX = image.size.width / geometry.size.width
                            let scaleY = image.size.height / geometry.size.height
                            let point = CGPoint(x: value.location.x * scaleX, y: value.location.y * scaleY)
                            if let color = image.pixelColor(at: point) {
                                onColorSelected(color)
                            }
                        }
                )
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension UIImage {
    func pixelColor(at point: CGPoint) -> UIColor? {
        guard let cgImage = self.cgImage,
              let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data else { return nil }
        let dataPtr = CFDataGetBytePtr(data)
        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let x = Int(point.x)
        let y = Int(point.y)
        guard x >= 0, x < cgImage.width, y >= 0, y < cgImage.height else { return nil }
        let offset = y * bytesPerRow + x * bytesPerPixel
        let r = dataPtr[offset]
        let g = dataPtr[offset + 1]
        let b = dataPtr[offset + 2]
        let a = dataPtr[offset + 3]
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
    }
}

extension UIColor {
    var hsbComponents: (hue: Double, saturation: Double, brightness: Double) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (Double(h) * 360.0, Double(s), Double(b))
    }
}

#Preview {
    PhotoColorPickerView()
}
