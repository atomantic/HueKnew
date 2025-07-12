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
                                isPrimaryColor: true
                            )
                            
                            // Comparison color
                            ColorDisplayCard(
                                colorInfo: colorPair.comparisonColor,
                                isSelected: false,
                                showDescription: true,
                                learningNotes: colorPair.learningNotes,
                                isPrimaryColor: false
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
            
            // Color characteristics badges
            HStack(spacing: 8) {
                CharacteristicBadge(
                    icon: "thermometer",
                    text: temperatureText,
                    color: temperatureColor
                )
                CharacteristicBadge(
                    icon: "drop.fill",
                    text: saturationText,
                    color: saturationColor
                )
                CharacteristicBadge(
                    icon: "sun.max.fill",
                    text: brightnessText,
                    color: brightnessColor
                )
            }
            
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
    
    // MARK: - Computed Properties
    private var temperatureText: String {
        let temp = ColorDatabase.shared.temperatureCategory(for: colorInfo)
        return temp.capitalized
    }
    
    private var temperatureColor: Color {
        let temp = ColorDatabase.shared.temperatureCategory(for: colorInfo)
        return temp == "warm" ? .orange : .blue
    }
    
    private var saturationText: String {
        let sat = ColorDatabase.shared.saturationLevel(for: colorInfo)
        return sat.capitalized
    }
    
    private var saturationColor: Color {
        let sat = ColorDatabase.shared.saturationLevel(for: colorInfo)
        switch sat {
        case "low": return .gray
        case "medium": return .purple
        default: return .pink
        }
    }
    
    private var brightnessText: String {
        let bright = ColorDatabase.shared.brightnessLevel(for: colorInfo)
        return bright.capitalized
    }
    
    private var brightnessColor: Color {
        let bright = ColorDatabase.shared.brightnessLevel(for: colorInfo)
        switch bright {
        case "dark": return .black
        case "medium": return .brown
        default: return .yellow
        }
    }
}

// MARK: - Characteristic Badge
struct CharacteristicBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            Text(text)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .cornerRadius(8)
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
