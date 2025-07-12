//
//  ColorWheelPicker.swift
//  HueKnew
//
//  Created by Adam Eivy on 7/12/25.
//

import SwiftUI

struct ColorWheelPicker: View {
    @State private var selectedHue: Double = 0
    @State private var selectedSaturation: Double = 0.8
    @State private var selectedValue: Double = 0.8
    let onColorSelected: (HSBColor) -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Wheel and vertical Value slider side by side
            HStack(spacing: 20) {
                ColorWheelView(
                    selectedHue: $selectedHue,
                    selectedSaturation: $selectedSaturation
                )
                .frame(width: 250, height: 250)

                // Vertical Value slider (like Blender)
                VStack(spacing: 8) {
                    Slider(value: $selectedValue, in: 0...1)
                        .rotationEffect(.degrees(-90.0))
                        .frame(width: 200, height: 20)
                        .accentColor(
                            Color(
                                hue: selectedHue / 360.0,
                                saturation: selectedSaturation,
                                brightness: 1.0
                            )
                        )
                }
                .frame(width: 40)
            }

            // Hue & Saturation sliders
            VStack(spacing: 12) {
                HStack {
                    Text("Hue")
                        .frame(width: 80, alignment: .leading)
                    Slider(value: $selectedHue, in: 0...360)
                }
                HStack {
                    Text("Saturation")
                        .frame(width: 80, alignment: .leading)
                    Slider(value: $selectedSaturation, in: 0...1)
                }
            }
            .padding(.horizontal)

            // Color preview and action button
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        Color(
                            hue: selectedHue / 360.0,
                            saturation: selectedSaturation,
                            brightness: selectedValue
                        )
                    )
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                    )

                Button(action: {
                    onColorSelected(
                        HSBColor(
                            hue: selectedHue,
                            saturation: selectedSaturation,
                            brightness: selectedValue
                        )
                    )
                }) {
                    Text("Find Similar Colors")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ColorWheelView: View {
    @Binding var selectedHue: Double
    @Binding var selectedSaturation: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Hue Wheel
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: hueColors),
                            center: .center
                        )
                    )
                    .overlay(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.8),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width / 2.0
                        )
                    )

                // Selection Indicator
                let maxRadius = geometry.size.width / 2.0 - 10.0
                let radius = maxRadius * CGFloat(selectedSaturation)
                let angleRad = CGFloat(selectedHue) * .pi / 180.0
                let centerX = geometry.size.width / 2.0
                let centerY = geometry.size.height / 2.0
                let indicatorX = centerX + cos(angleRad) * radius
                let indicatorY = centerY + sin(angleRad) * radius

                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 20, height: 20)
                    .position(x: indicatorX, y: indicatorY)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let center = CGPoint(
                            x: geometry.size.width / 2.0,
                            y: geometry.size.height / 2.0
                        )
                        let dx = value.location.x - center.x
                        let dy = value.location.y - center.y
                        let dist = sqrt(dx * dx + dy * dy)
                        let maxR = geometry.size.width / 2.0 - 10.0

                        var angleDeg = atan2(dy, dx) * 180.0 / .pi
                        if angleDeg < 0 { angleDeg += 360.0 }
                        selectedHue = angleDeg
                        selectedSaturation = min(dist / maxR, 1.0)
                    }
            )
        }
    }

    private var hueColors: [Color] {
        (0...360).map { i in
            Color(hue: Double(i) / 360.0, saturation: 1.0, brightness: 1.0)
        }
    }
}

struct HSBColor {
    let hue: Double
    let saturation: Double
    let brightness: Double

    var color: Color {
        Color(hue: hue / 360.0, saturation: saturation, brightness: brightness)
    }

    var description: String {
        let names = [
            "Red", "Red-Orange", "Orange", "Yellow-Orange", "Yellow",
            "Yellow-Green", "Green", "Blue-Green", "Blue",
            "Blue-Purple", "Purple", "Red-Purple"
        ]
        return names[Int(hue / 30) % names.count]
    }
}

#Preview {
    ColorWheelPicker { color in
        print(color.description)
    }
}
