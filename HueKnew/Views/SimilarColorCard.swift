import SwiftUI

struct SimilarColorCard: View {
    let colorInfo: ColorInfo
    let baseColor: ColorInfo

    var body: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(colorInfo.color)
                .frame(height: 120)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )

            Text(colorInfo.name)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(colorInfo.hexValue)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                let characteristics = ColorDatabase.shared.getColorComparisons(color1: colorInfo, color2: baseColor)
                if characteristics.isEmpty {
                    Text("Identical for human eyes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("No differences found between colors")
                } else {
                    ForEach(Array(characteristics.enumerated()), id: \.offset) { _, characteristic in
                        HStack(alignment: .top, spacing: 4) {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .accessibilityHidden(true)
                            Text(characteristic)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .accessibilityLabel("\(colorInfo.name) is \(characteristic.lowercased()) than \(baseColor.name)")
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    SimilarColorCard(
        colorInfo: ColorInfo(name: "Gamboge", hexValue: "#E49B0F", description: "", category: .yellows),
        baseColor: ColorInfo(name: "Indian Yellow", hexValue: "#E3B505", description: "", category: .yellows)
    )
}
