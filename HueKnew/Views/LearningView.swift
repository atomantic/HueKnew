//
//  LearningView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

struct LearningView: View {
    let colorPair: ColorPair
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with learning mode indicator
            VStack(spacing: 8) {
                Text("Learning Mode")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("Study the differences")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Difficulty level indicator
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(colorPair.difficultyLevel.color)
                        Text(colorPair.difficultyLevel.rawValue)
                            .font(.subheadline)
                            .foregroundColor(colorPair.difficultyLevel.color)
                        Spacer()
                        Text(colorPair.category.emoji + " " + colorPair.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Side-by-side color comparison
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            // Primary color
                            ColorDisplayCard(
                                colorInfo: colorPair.primaryColor,
                                isSelected: false,
                                showDescription: true,
                                learningNotes: colorPair.learningNotes,
                                isPrimaryColor: true,
                                colorPair: colorPair
                            )
                            
                            // Comparison color
                            ColorDisplayCard(
                                colorInfo: colorPair.comparisonColor,
                                isSelected: false,
                                showDescription: true,
                                learningNotes: colorPair.learningNotes,
                                isPrimaryColor: false,
                                colorPair: colorPair
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Continue button
                    Button(action: onContinue) {
                        Text("Ready to Practice!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

struct ColorDisplayCard: View {
    let colorInfo: ColorInfo
    let isSelected: Bool
    let showDescription: Bool
    let learningNotes: String
    let isPrimaryColor: Bool
    let colorPair: ColorPair
    
    var body: some View {
        VStack(spacing: 12) {
            // Color swatch
            Rectangle()
                .fill(colorInfo.color)
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
                .cornerRadius(12)
                .shadow(radius: isSelected ? 8 : 4)
            
            // Color name
            Text(colorInfo.name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Hex value
            Text(colorInfo.hexValue)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(6)
            
            // Description (if shown)
            if showDescription {
                Text(colorInfo.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 4)
                
                // Comparative characteristics
                VStack(alignment: .leading, spacing: 2) {
                    let characteristics = getComparativeCharacteristics()
                    if characteristics.isEmpty {
                        Text("No differences found")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(characteristics, id: \.self) { characteristic in
                            HStack(alignment: .top, spacing: 4) {
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(characteristic)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
                
                // Learning notes (if shown)
                if !learningNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Key Differences:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                        
                        // Split learning notes into bullet points
                        ForEach(parseLearningNotes(learningNotes), id: \.self) { note in
                            HStack(alignment: .top, spacing: 4) {
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(note)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Helper Methods
    private func getComparativeCharacteristics() -> [String] {
        // Get the other color from the color pair
        let otherColor = isPrimaryColor ? colorPair.comparisonColor : colorPair.primaryColor
        
        print("DEBUG: Comparing \(colorInfo.name) with \(otherColor.name)")
        
        // Debug HSB values
        let hsb1 = colorInfo.hsbComponents
        let hsb2 = otherColor.hsbComponents
        print("DEBUG: \(colorInfo.name) HSB: (\(hsb1.hue), \(hsb1.saturation), \(hsb1.brightness))")
        print("DEBUG: \(otherColor.name) HSB: (\(hsb2.hue), \(hsb2.saturation), \(hsb2.brightness))")
        
        var characteristics: [String] = []
        
        // Compare hue (temperature)
        let hueDiff = hsb1.hue - hsb2.hue
        let normalizedHueDiff = abs(hueDiff) > 180 ? 360 - abs(hueDiff) : abs(hueDiff)
        if normalizedHueDiff > 5 { // Only show if there's a meaningful difference
            // Add color-specific descriptions
            let colorDescription = getColorDescription(hue1: hsb1.hue, hue2: hsb2.hue)
            if !colorDescription.isEmpty {
                characteristics.append(colorDescription)
            }
        }
        
        // Compare saturation
        let satDiff = hsb1.saturation - hsb2.saturation
        if abs(satDiff) > 0.05 { // Only show if there's a meaningful difference
            if satDiff > 0 {
                characteristics.append("More Saturated")
            } else {
                characteristics.append("Less Saturated")
            }
        }
        
        // Compare brightness
        let brightDiff = hsb1.brightness - hsb2.brightness
        if abs(brightDiff) > 0.05 { // Only show if there's a meaningful difference
            if brightDiff > 0 {
                characteristics.append("Brighter")
            } else {
                characteristics.append("Darker")
            }
        }
        
        print("DEBUG: Final characteristics for \(colorInfo.name): \(characteristics)")
        return characteristics
    }
    
    private func getColorDescription(hue1: Double, hue2: Double) -> String {
        let hueDiff = hue1 - hue2
        let normalizedHueDiff = abs(hueDiff) > 180 ? 360 - abs(hueDiff) : abs(hueDiff)
        
        // Only provide color descriptions for meaningful differences
        guard normalizedHueDiff > 10 else { return "" }
        
        // Define hue ranges for different colors (adjusted for better accuracy)
        let redRange = 350.0...360.0
        let redOrangeRange = 0.0...15.0
        let orangeRange = 15.0...45.0
        let yellowOrangeRange = 45.0...75.0
        let yellowRange = 75.0...105.0
        let yellowGreenRange = 105.0...135.0
        let greenRange = 135.0...165.0
        let blueGreenRange = 165.0...195.0
        let blueRange = 195.0...255.0
        let purpleRange = 255.0...285.0
        let magentaRange = 285.0...315.0
        let pinkRange = 315.0...350.0
        
        func getColorName(for hue: Double) -> String {
            let normalizedHue = hue < 0 ? hue + 360 : hue
            
            if redRange.contains(normalizedHue) {
                return "red"
            } else if redOrangeRange.contains(normalizedHue) {
                return "red-orange"
            } else if orangeRange.contains(normalizedHue) {
                return "orange"
            } else if yellowOrangeRange.contains(normalizedHue) {
                return "yellow-orange"
            } else if yellowRange.contains(normalizedHue) {
                return "yellow"
            } else if yellowGreenRange.contains(normalizedHue) {
                return "yellow-green"
            } else if greenRange.contains(normalizedHue) {
                return "green"
            } else if blueGreenRange.contains(normalizedHue) {
                return "blue-green"
            } else if blueRange.contains(normalizedHue) {
                return "blue"
            } else if purpleRange.contains(normalizedHue) {
                return "purple"
            } else if magentaRange.contains(normalizedHue) {
                return "magenta"
            } else if pinkRange.contains(normalizedHue) {
                return "pink"
            } else {
                return "red" // Default for edge cases
            }
        }
        
        let color1 = getColorName(for: hue1)
        let color2 = getColorName(for: hue2)
        
        if color1 != color2 {
            return "More \(color1.replacingOccurrences(of: "-", with: " ").capitalized)"
        } else {
            // Same color family, but different shades
            if abs(hueDiff) > 20 {
                if hueDiff > 0 && hueDiff < 180 || hueDiff < -180 {
                    return "More \(color1.replacingOccurrences(of: "-", with: " ").capitalized)"
                } else {
                    return "Less \(color1.replacingOccurrences(of: "-", with: " ").capitalized)"
                }
            }
        }
        
        return ""
    }
}

// MARK: - Helper Functions
private func parseLearningNotes(_ notes: String) -> [String] {
    return notes
        .split(separator: ".")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}

#Preview {
    LearningView(
        colorPair: ColorPair(
            primaryColor: ColorInfo(
                name: "Gamboge",
                hexValue: "#E49B0F",
                description: "A deep golden yellow with warm undertones",
                category: .yellows
            ),
            comparisonColor: ColorInfo(
                name: "Indian Yellow",
                hexValue: "#E3B505",
                description: "A rich, warm yellow with orange undertones",
                category: .yellows
            ),
            learningNotes: "Gamboge has more brown/amber undertones, while Indian Yellow is purer and brighter with orange hints.",
            category: .yellows
        ),
        onContinue: { }
    )
}
