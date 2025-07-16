import SwiftUI
import PhotosUI

struct CameraColorPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var touchLocation: CGPoint = .zero
    @State private var selectedColor: Color = .clear
    @State private var colorName: String = ""

    var body: some View {
        ZStack {
            if let image {
                ZoomableColorImage(image: image, touchLocation: $touchLocation, selectedColor: $selectedColor, colorName: $colorName)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            if image == nil {
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Label("Take Photo", systemImage: "camera")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }

            if !colorName.isEmpty {
                Text(colorName)
                    .font(.caption)
                    .padding(6)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .position(x: touchLocation.x, y: touchLocation.y - 60)
            }

            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 80, height: 80)
                .position(touchLocation)
            Circle()
                .fill(selectedColor)
                .frame(width: 40, height: 40)
                .position(touchLocation)

            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onChange(of: selectedItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    image = UIImage(data: data)
                }
            }
        }
    }
}

struct ZoomableColorImage: View {
    let image: UIImage
    @Binding var touchLocation: CGPoint
    @Binding var selectedColor: Color
    @Binding var colorName: String

    @State private var scale: CGFloat = 1.0
    @GestureState private var tempScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var tempOffset: CGSize = .zero
    private let colorDatabase = ColorDatabase.shared

    var body: some View {
        GeometryReader { geo in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale * tempScale)
                .offset(x: offset.width + tempOffset.width,
                        y: offset.height + tempOffset.height)
                .gesture(
                    MagnificationGesture()
                        .updating($tempScale) { value, state, _ in
                            state = value
                        }
                        .onEnded { value in
                            scale *= value
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .updating($tempOffset) { value, state, _ in
                            state = value.translation
                            touchLocation = value.location
                            updateColor(at: value.location, in: geo)
                        }
                        .onEnded { value in
                            offset.width += value.translation.width
                            offset.height += value.translation.height
                        }
                )
        }
    }

    private func updateColor(at location: CGPoint, in geo: GeometryProxy) {
        let imgSize = image.size
        let viewSize = geo.size
        let baseScale = min(viewSize.width / imgSize.width, viewSize.height / imgSize.height)
        let displaySize = CGSize(width: imgSize.width * baseScale * scale, height: imgSize.height * baseScale * scale)
        let origin = CGPoint(x: (viewSize.width - displaySize.width) / 2 + offset.width, y: (viewSize.height - displaySize.height) / 2 + offset.height)
        let relativeX = (location.x - origin.x) / displaySize.width
        let relativeY = (location.y - origin.y) / displaySize.height
        guard relativeX >= 0, relativeY >= 0, relativeX < 1, relativeY < 1 else { return }
        let imgPoint = CGPoint(x: imgSize.width * relativeX, y: imgSize.height * relativeY)
        if let uiColor = image.color(at: imgPoint) {
            selectedColor = Color(uiColor)
            let hsb = uiColor.hsbComponents
            if let closest = colorDatabase.closestColor(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness) {
                colorName = closest.name
            } else {
                colorName = ""
            }
        }
    }
}

private extension UIImage {
    func color(at point: CGPoint) -> UIColor? {
        guard let cgImage else { return nil }
        return cgImage.color(at: point)
    }
}

private extension CGImage {
    func color(at point: CGPoint) -> UIColor? {
        guard let dataProvider = dataProvider, let data = dataProvider.data else { return nil }
        let pixelData = CFDataGetBytePtr(data)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let x = Int(point.x)
        let y = Int(point.y)
        guard x >= 0, y >= 0, x < width, y < height else { return nil }
        let index = y * bytesPerRow + x * bytesPerPixel
        let r = CGFloat(pixelData[index]) / 255.0
        let g = CGFloat(pixelData[index + 1]) / 255.0
        let b = CGFloat(pixelData[index + 2]) / 255.0
        let a = CGFloat(pixelData[index + 3]) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

private extension UIColor {
    var hsbComponents: (hue: Double, saturation: Double, brightness: Double) {
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bri: CGFloat = 0
        var alpha: CGFloat = 0
        getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        return (Double(hue) * 360.0, Double(sat), Double(bri))
    }
}

#Preview {
    CameraColorPickerView()
}
