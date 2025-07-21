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
    /// Size of the square sampled when determining a color
    /// One pixel larger than the on-screen indicator to avoid rounding issues
    private let sampleSize: CGFloat = 9
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

                if mode == .ar {
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 6, height: 6)
                }

                if let baseImage = currentImage, showSelector, mode != .ar {
                    MagnifierView(image: baseImage, imagePoint: imagePoint)
                        .frame(width: 120, height: 120)
                        .position(x: touchLocation.x, y: max(CGFloat(60), touchLocation.y - 150))
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
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    updateColor(at: center, in: geo)
                }
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
        if mode == .ar {
            return liveFrame
        } else {
            return image?.normalizedOrientation()
        }
    }

    private func updateColor(at location: CGPoint, in geo: GeometryProxy) {
        guard let img = currentImage,
              let imgPoint = imagePoint(for: location, in: geo, image: img) else { return }
        imagePoint = imgPoint

        DispatchQueue.global(qos: .userInitiated).async {
            let intSize = Int(sampleSize)
            let x = Int(round(imgPoint.x)) - intSize / 2
            let y = Int(round(imgPoint.y)) - intSize / 2
            let rect = CGRect(x: x, y: y, width: intSize, height: intSize)
            if let uiColor = img.averageColor(in: rect) {
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
        if let connection = preview.connection {
            connection.videoRotationAngle = 0
        }
        view.layer.addSublayer(preview)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame"))
        if let connection = output.connection(with: .video) {
            connection.videoRotationAngle = 0
        }
        session.addOutput(output)
        session.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: buffer)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let frameImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
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
    func averageColor(in rect: CGRect) -> UIColor? {
        guard let cgImage else { return nil }
        return cgImage.averageColor(in: rect)
    }
    func normalizedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        let shouldSwap = imageOrientation == .right || imageOrientation == .left ||
            imageOrientation == .rightMirrored || imageOrientation == .leftMirrored
        let newSize = shouldSwap ? CGSize(width: size.height, height: size.width) : size
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }

}

private extension CGImage {
    struct ChannelOffsets { let r: Int; let g: Int; let b: Int; let a: Int }

    var channelOffsets: ChannelOffsets {
        let info = bitmapInfo
        let alphaInfo = CGImageAlphaInfo(rawValue: info.rawValue & CGBitmapInfo.alphaInfoMask.rawValue)
        let littleEndian = info.contains(.byteOrder32Little)
        switch (alphaInfo, littleEndian) {
        case (.premultipliedFirst, true), (.first, true), (.noneSkipFirst, true):
            return ChannelOffsets(r: 2, g: 1, b: 0, a: 3) // BGRA
        default:
            return ChannelOffsets(r: 0, g: 1, b: 2, a: 3) // Assume RGBA
        }
    }
    func color(at point: CGPoint) -> UIColor? {
        guard let dataProvider = dataProvider,
              let data = dataProvider.data,
              let pixelData = CFDataGetBytePtr(data) else { return nil }
        let bytesPerPixel = 4
        let bytesPerRow = self.bytesPerRow
        let x = Int(point.x)
        let y = Int(point.y)
        guard x >= 0, y >= 0, x < width, y < height else { return nil }
        let offsets = channelOffsets
        let index = y * bytesPerRow + x * bytesPerPixel
        let r = CGFloat(pixelData[index + offsets.r]) / 255.0
        let g = CGFloat(pixelData[index + offsets.g]) / 255.0
        let b = CGFloat(pixelData[index + offsets.b]) / 255.0
        let a = CGFloat(pixelData[index + offsets.a]) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    func averageColor(in rect: CGRect) -> UIColor? {
        guard rect.width > 0, rect.height > 0 else { return nil }
        guard let dataProvider = dataProvider,
              let data = dataProvider.data,
              let pixelData = CFDataGetBytePtr(data) else { return nil }
        let bytesPerPixel = 4
        let bytesPerRow = self.bytesPerRow
        let offsets = channelOffsets
        let x0 = max(Int(rect.minX), 0)
        let y0 = max(Int(rect.minY), 0)
        let x1 = min(Int(rect.maxX - 1), width - 1)
        let y1 = min(Int(rect.maxY - 1), height - 1)
        guard x1 >= x0, y1 >= y0 else { return nil }
        var rTotal: Int = 0
        var gTotal: Int = 0
        var bTotal: Int = 0
        var aTotal: Int = 0
        var count: Int = 0
        for y in y0...y1 {
            for x in x0...x1 {
                let index = y * bytesPerRow + x * bytesPerPixel
                rTotal += Int(pixelData[index + offsets.r])
                gTotal += Int(pixelData[index + offsets.g])
                bTotal += Int(pixelData[index + offsets.b])
                aTotal += Int(pixelData[index + offsets.a])
                count += 1
            }
        }
        guard count > 0 else { return nil }
        let r = CGFloat(rTotal) / CGFloat(count) / 255.0
        let g = CGFloat(gTotal) / CGFloat(count) / 255.0
        let b = CGFloat(bTotal) / CGFloat(count) / 255.0
        let a = CGFloat(aTotal) / CGFloat(count) / 255.0
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
