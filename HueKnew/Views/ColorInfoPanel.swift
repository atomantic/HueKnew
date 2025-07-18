import SwiftUI

struct ColorInfoPanel: View {
    let colorInfo: ColorInfo
    let onInfo: () -> Void

    var body: some View {
        Button(action: onInfo) {
            HStack(spacing: 12) {
                Circle()
                    .fill(colorInfo.color)
                    .frame(width: 32, height: 32)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                Text(colorInfo.name)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "info.circle")
                    .font(.title3)
            }
        }
        .padding(12)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(12)
    }
}

#Preview {
    ColorInfoPanel(colorInfo: ColorInfo(name: "Red", hexValue: "FF0000", description: "", category: .reds)) {}
}
