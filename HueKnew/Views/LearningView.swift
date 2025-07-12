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
        
        // Use shared comparison logic from ColorDatabase
        let comparisons = ColorDatabase.shared.getColorComparisons(color1: colorInfo, color2: otherColor)
        
        print("DEBUG: \(colorInfo.name) vs \(otherColor.name) - comparisons: \(comparisons)")
        return comparisons
    }
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
