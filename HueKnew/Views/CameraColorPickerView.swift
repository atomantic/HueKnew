import SwiftUI
import AVFoundation
import PhotosUI

enum CameraMode: String, CaseIterable, Identifiable {
    case ar = "AR"
    case photos = "Photos"
    var id: String { rawValue }
}

struct CameraColorPickerView: View {
    @State private var mode: CameraMode = .ar
    @State private var image: UIImage?
    @State private var liveFrame: UIImage?
    @State private var showPhotoPicker = false
    @State private var showColorDetail = false
    @State private var touchLocation: CGPoint = .zero
    @State private var colorName: String = ""
    @State private var selectedColorInfo: ColorInfo?
    @State private var showSelector = false
    @State private var imagePoint: CGPoint = .zero
    private let colorDatabase = ColorDatabase.shared

    var body: some View {
        GeometryReader { geo in
            let sampleGesture = DragGesture(minimumDistance: 0)
                .onChanged { value in
                    touchLocation = value.location
                    showSelector = true
                    updateColor(at: value.location, in: geo)
                }
                .onEnded { _ in
                    showSelector = false
                }

            ZStack {
                contentView(sampleGesture: sampleGesture)
                    .ignoresSafeArea(edges: .top)

                if let baseImage = currentImage, showSelector {
                    MagnifierView(image: baseImage, imagePoint: imagePoint)
                        .frame(width: 120, height: 120)
                        .position(x: touchLocation.x, y: max(CGFloat(60), touchLocation.y - 150))
                }


                VStack {
                    ColorInfoPanel(color: selectedColorInfo?.color ?? .clear, name: colorName) {
                        showColorDetail = true
                    }
                        .opacity(colorName.isEmpty ? 0 : 1)
                    Spacer()
                    ModePicker(selection: $mode)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 8)
                }
                .padding(.horizontal)
            }
        }
        .onChange(of: mode) { _, newMode in
            if newMode == .photos {
                showPhotoPicker = true
            }
        }
        
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(image: $image)
                .onDisappear {
                    if image == nil { mode = .ar }
                }
        }
        .sheet(isPresented: $showColorDetail) {
            if let colorInfo = selectedColorInfo {
                ColorDetailView(color: colorInfo)
            }
        }
    }

    private func contentView(sampleGesture: some Gesture) -> some View {
        Group {
            if mode == .ar {
                LiveCameraView(frame: $liveFrame)
                    .gesture(sampleGesture)
            } else if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .gesture(sampleGesture)
            } else {
                Color.black
            }
        }
    }

    private var currentImage: UIImage? {
        if mode == .ar { return liveFrame } else { return image }
    }

    private func updateColor(at location: CGPoint, in geo: GeometryProxy) {
        guard let img = currentImage,
              let imgPoint = imagePoint(for: location, in: geo, image: img) else { return }
        imagePoint = imgPoint
        if let uiColor = img.color(at: imgPoint) {
            let hsb = uiColor.hsbComponents
            if let closest = colorDatabase.closestColor(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness) {
                colorName = closest.name
                selectedColorInfo = closest
            } else {
                colorName = ""
                selectedColorInfo = nil
            }
        }
    }

    private func imagePoint(for location: CGPoint, in geo: GeometryProxy, image: UIImage) -> CGPoint? {
        let imgSize = image.size
        let viewSize = geo.size
        let baseScale: CGFloat = mode == .ar
            ? max(viewSize.width / imgSize.width, viewSize.height / imgSize.height)
            : min(viewSize.width / imgSize.width, viewSize.height / imgSize.height)
        let displaySize = CGSize(width: imgSize.width * baseScale, height: imgSize.height * baseScale)
        let originX = (viewSize.width - displaySize.width) / 2
        let originY: CGFloat = mode == .ar
            ? (viewSize.height - displaySize.height) / 2
            : (viewSize.height - displaySize.height) / 2
        let relativeX = (location.x - originX) / displaySize.width
        let relativeY = (location.y - originY) / displaySize.height
        guard relativeX >= 0, relativeY >= 0, relativeX <= 1, relativeY <= 1 else { return nil }
        return CGPoint(x: imgSize.width * relativeX, y: imgSize.height * relativeY)
    }
}

struct ModePicker: View {
    @Binding var selection: CameraMode
    var body: some View {
        Picker("", selection: $selection) {
            ForEach(CameraMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(6)
        .background(Color(.systemBackground).opacity(0.8))
        .clipShape(Capsule())
    }
}

struct ColorInfoPanel: View {
    let color: Color
    let name: String
    let onInfo: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(Circle().stroke(Color.white, lineWidth: 1))
            Text(name)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Button(action: onInfo) {
                Image(systemName: "info.circle")
                    .font(.title3)
            }
        }
        .padding(12)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(12)
    }
}


struct MagnifierView: View {
    let image: UIImage
    let imagePoint: CGPoint

    var body: some View {
        let cropSize: CGFloat = 80
        let originX = max(min(imagePoint.x - cropSize / 2, image.size.width - cropSize), 0)
        let originY = max(min(imagePoint.y - cropSize / 2, image.size.height - cropSize), 0)
        let rect = CGRect(x: originX, y: originY, width: cropSize, height: cropSize)
        let cropped = image.cgImage?.cropping(to: rect).map { UIImage(cgImage: $0) } ?? image
        return Image(uiImage: cropped)
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .overlay(
                Rectangle()
                    .stroke(Color.white, lineWidth: 1)
                    .frame(width: 8, height: 8)
            )
            .overlay(alignment: .bottom) {
                StingerShape()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(y: 10)
            }
    }
}

struct StingerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        init(_ parent: PhotoPickerView) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let uiImage = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.image = uiImage.normalizedOrientation()
                        }
                    }
                }
            }
            parent.dismiss()
        }
    }
}

protocol CameraControllerDelegate: AnyObject {
    func didOutput(image: UIImage)
}

class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: CameraControllerDelegate?
    private let session = AVCaptureSession()
    private let context = CIContext()

    override func viewDidLoad() {
        super.viewDidLoad()
        session.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.addInput(input)

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        if let connection = preview.connection {
            connection.videoOrientation = .portrait
        }
        view.layer.addSublayer(preview)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame"))
        if let connection = output.connection(with: .video) {
            connection.videoOrientation = .portrait
        }
        session.addOutput(output)
        session.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: buffer)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let frameImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
            delegate?.didOutput(image: frameImage)
        }
    }
}

struct LiveCameraView: UIViewControllerRepresentable {
    @Binding var frame: UIImage?

    func makeUIViewController(context: Context) -> CameraController {
        let controller = CameraController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraControllerDelegate {
        let parent: LiveCameraView
        init(_ parent: LiveCameraView) { self.parent = parent }
        func didOutput(image: UIImage) {
            DispatchQueue.main.async {
                self.parent.frame = image
            }
        }
    }
}

private extension UIImage {
    func color(at point: CGPoint) -> UIColor? {
        guard let cgImage else { return nil }
        return cgImage.color(at: point)
    }
    func normalizedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }

}

private extension CGImage {
    func color(at point: CGPoint) -> UIColor? {
        guard let dataProvider = dataProvider,
              let data = dataProvider.data,
              let pixelData = CFDataGetBytePtr(data) else { return nil }
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
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (Double(h) * 360.0, Double(s), Double(b))
    }
}

#Preview {
    CameraColorPickerView()
}
