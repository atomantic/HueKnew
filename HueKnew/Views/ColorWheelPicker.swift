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
    @State private var selectedBrightness: Double = 0.8
    @State private var isDragging = false
    
    let onColorSelected: (HSBColor) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Color Wheel
            ColorWheelView(
                selectedHue: $selectedHue,
                selectedSaturation: $selectedSaturation,
                selectedBrightness: $selectedBrightness,
                isDragging: $isDragging
            )
            .frame(width: 250, height: 250)
            
            // Saturation and Brightness controls
            VStack(spacing: 16) {
                // Saturation slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Saturation")
                            .font(.headline)
                        Spacer()
                        Text(saturationType)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("0%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $selectedSaturation, in: 0...1)
                            .accentColor(Color(hue: selectedHue/360, saturation: 1.0, brightness: selectedBrightness))
                        
                        Text("100%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Brightness slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Brightness")
                            .font(.headline)
                        Spacer()
                        Text(brightnessType)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("0%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $selectedBrightness, in: 0...1)
                            .accentColor(Color(hue: selectedHue/360, saturation: selectedSaturation, brightness: 1.0))
                        
                        Text("100%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            
            // Color preview and action button
            VStack(spacing: 12) {
                // Selected color preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hue: selectedHue/360, saturation: selectedSaturation, brightness: selectedBrightness))
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                    )
                
                // Action button
                Button(action: {
                    onColorSelected(HSBColor(
                        hue: selectedHue,
                        saturation: selectedSaturation,
                        brightness: selectedBrightness
                    ))
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
    
    private var saturationType: String {
        if selectedSaturation > 0.8 {
            return "Jewel Tones"
        } else if selectedSaturation < 0.3 {
            return "Pastels"
        } else {
            return "Medium"
        }
    }
    
    private var brightnessType: String {
        if selectedBrightness > 0.8 {
            return "Light"
        } else if selectedBrightness < 0.3 {
            return "Dark"
        } else {
            return "Medium"
        }
    }
}

struct ColorWheelView: View {
    @Binding var selectedHue: Double
    @Binding var selectedSaturation: Double
    @Binding var selectedBrightness: Double
    @Binding var isDragging: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                colorWheelBackground(in: geometry)
                selectionIndicator(in: geometry)
            }
            .contentShape(Circle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        updateSelection(at: value.location, in: geometry)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .onTapGesture { location in
                updateSelection(at: location, in: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func colorWheelBackground(in geometry: GeometryProxy) -> some View {
        Circle()
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: hueColors),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                )
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.8),
                        Color.white.opacity(0.1),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: geometry.size.width / 2
                )
            )
    }
    
    @ViewBuilder
    private func selectionIndicator(in geometry: GeometryProxy) -> some View {
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        let maxRadius = geometry.size.width / 2 - 20
        let radius = maxRadius * selectedSaturation
        let angle = selectedHue * .pi / 180
        
        Circle()
            .fill(Color.white)
            .frame(width: 20, height: 20)
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 2)
            )
            .offset(
                x: CGFloat(cos(angle)) * radius,
                y: CGFloat(sin(angle)) * radius
            )
            .shadow(radius: 2)
    }
    
    private func updateSelection(at location: CGPoint, in geometry: GeometryProxy) {
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        let vector = CGPoint(x: location.x - center.x, y: location.y - center.y)
        let distance = sqrt(vector.x * vector.x + vector.y * vector.y)
        let maxRadius = geometry.size.width / 2 - 20
        
        // Calculate angle (hue)
        let angle = atan2(vector.y, vector.x) * 180 / .pi
        selectedHue = angle < 0 ? angle + 360 : angle
        
        // Calculate saturation based on distance from center
        selectedSaturation = min(distance / maxRadius, 1.0)
    }
    
    private var hueColors: [Color] {
        // Reduce the number of colors to improve performance
        var colors: [Color] = []
        for i in stride(from: 0, to: 360, by: 6) {
            colors.append(Color(hue: Double(i) / 360.0, saturation: 1.0, brightness: selectedBrightness))
        }
        return colors
    }
}

struct HSBColor {
    let hue: Double
    let saturation: Double
    let brightness: Double
    
    var color: Color {
        Color(hue: hue / 360, saturation: saturation, brightness: brightness)
    }
    
    var hueSegment: Int {
        Int(hue / 30) % 12
    }
    
    var description: String {
        let hueNames = ["Red", "Red-Orange", "Orange", "Yellow-Orange", "Yellow", "Yellow-Green", 
                       "Green", "Blue-Green", "Blue", "Blue-Purple", "Purple", "Red-Purple"]
        return hueNames[hueSegment]
    }
}

#Preview {
    ColorWheelPicker { hsbColor in
        print("Selected color: \(hsbColor.description)")
    }
    .padding()
}
