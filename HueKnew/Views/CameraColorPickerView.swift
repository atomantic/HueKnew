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
    @State private var nearbyColors: [ColorInfo] = []
    @State private var lastARUpdate = Date()
    private let arUpdateInterval: TimeInterval = 0.6
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
                    MagnifierView(image: baseImage, imagePoint: imagePoint, isARMode: mode == .ar)
                        .frame(width: 120, height: 120)
                        .position(x: touchLocation.x, y: mode == .ar ? min(touchLocation.y + 150, geo.size.height - 60) : max(CGFloat(60), touchLocation.y - 150))
                }

                // AR mode center magnifier
                if mode == .ar, let baseImage = currentImage {
                    let magnifierY = geo.size.height / 2
                    let stingerOffset: CGFloat = 70 // Offset to where the stinger points
                    let samplePoint = CGPoint(x: geo.size.width / 2, y: magnifierY + stingerOffset)
                    
                    if let imgPoint = imagePoint(for: samplePoint, in: geo, image: baseImage) {
                        MagnifierView(image: baseImage, imagePoint: imgPoint, isARMode: true)
                            .frame(width: 120, height: 120)
                            .position(x: geo.size.width / 2, y: magnifierY)
                    }
                }

                VStack {
                    ForEach(nearbyColors) { info in
                        ColorInfoPanel(colorInfo: info) {
                            selectedColorInfo = info
                            showColorDetail = true
                        }
                    }
                    .opacity(nearbyColors.isEmpty ? 0 : 1)
                    Spacer()
                    ModePicker(selection: $mode)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 8)
                }
                .padding(.horizontal)
            }
            .onChange(of: liveFrame) { _, _ in
                if mode == .ar {
                    let now = Date()
                    guard now.timeIntervalSince(lastARUpdate) >= arUpdateInterval else { return }
                    lastARUpdate = now
                    let stingerOffset: CGFloat = 70 // Same offset as magnifier
                    let samplePoint = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2 + stingerOffset)
                    updateColor(at: samplePoint, in: geo)
                }
            }
        }
        .onChange(of: mode) { _, newMode in
            if newMode == .photos && image == nil {
                showPhotoPicker = true
            }
        }
        
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(image: $image)
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
            } else if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
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

        DispatchQueue.global(qos: .userInitiated).async {
            if let uiColor = img.color(at: imgPoint) {
                let hsb = uiColor.hsbComponents
                let matches = self.colorDatabase.nearestColors(
                    hue: hsb.hue,
                    saturation: hsb.saturation,
                    brightness: hsb.brightness,
                    count: 3
                )
                DispatchQueue.main.async {
                    self.nearbyColors = matches.sorted { $0.name < $1.name }
                    self.colorName = matches.first?.name ?? ""
                    self.selectedColorInfo = matches.first
                }
            } else {
                DispatchQueue.main.async {
                    self.nearbyColors = []
                    self.colorName = ""
                    self.selectedColorInfo = nil
                }
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
        
        // For photo mode, image is aligned to bottom; for AR mode, it's centered
        let originY: CGFloat = mode == .ar
            ? (viewSize.height - displaySize.height) / 2
            : viewSize.height - displaySize.height
        
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



struct MagnifierView: View {
    let image: UIImage
    let imagePoint: CGPoint
    let isARMode: Bool

    var body: some View {
        let cropSize: CGFloat = 80
        
        // Transform coordinates for AR mode due to image orientation
        let adjustedPoint: CGPoint
        let adjustedSize: CGSize
        
        if isARMode && image.imageOrientation == .right {
            // For .right orientation, transform coordinates
            adjustedPoint = CGPoint(x: imagePoint.y, y: image.size.width - imagePoint.x)
            adjustedSize = CGSize(width: image.size.height, height: image.size.width)
        } else {
            adjustedPoint = imagePoint
            adjustedSize = image.size
        }
        
        let originX = max(min(adjustedPoint.x - cropSize / 2, adjustedSize.width - cropSize), 0)
        let originY = max(min(adjustedPoint.y - cropSize / 2, adjustedSize.height - cropSize), 0)
        let rect = CGRect(x: originX, y: originY, width: cropSize, height: cropSize)
        let cropped = image.cgImage?.cropping(to: rect).map { UIImage(cgImage: $0, scale: image.scale, orientation: image.imageOrientation) } ?? image
        return Image(uiImage: cropped)
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .overlay(
                Rectangle()
                    .stroke(Color.white, lineWidth: 1)
                    .frame(width: 6, height: 6)
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
                            self.parent.image = uiImage
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
        view.layer.addSublayer(preview)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame"))
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
