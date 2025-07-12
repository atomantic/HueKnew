//
//  ColorPair.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI
import Foundation

struct ColorInfo: Identifiable, Codable, Equatable {
    var id: String { name }
    let name: String
    let hexValue: String
    let description: String
    let category: ColorCategory
    
    var color: Color {
        Color(hex: hexValue)
    }
    
    var rgbComponents: (red: Double, green: Double, blue: Double) {
        let hex = hexValue.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let red = Double((hexNumber & 0xFF0000) >> 16) / 255.0
            let green = Double((hexNumber & 0x00FF00) >> 8) / 255.0
            let blue = Double(hexNumber & 0x0000FF) / 255.0
            return (red, green, blue)
        }
        return (0, 0, 0)
    }
    
    var hsbComponents: (hue: Double, saturation: Double, brightness: Double) {
        let rgb = rgbComponents
        let max = Swift.max(rgb.red, rgb.green, rgb.blue)
        let min = Swift.min(rgb.red, rgb.green, rgb.blue)
        let delta = max - min
        
        var hue: Double = 0
        let saturation: Double = max == 0 ? 0 : delta / max
        let brightness: Double = max
        
        if delta != 0 {
            switch max {
            case rgb.red:
                hue = ((rgb.green - rgb.blue) / delta).truncatingRemainder(dividingBy: 6)
            case rgb.green:
                hue = (rgb.blue - rgb.red) / delta + 2
            case rgb.blue:
                hue = (rgb.red - rgb.green) / delta + 4
            default:
                hue = 0
            }
            hue *= 60
            if hue < 0 {
                hue += 360
            }
        }
        
        return (hue, saturation, brightness)
    }
}

struct ColorPair: Identifiable, Codable {
    var id: String { "\(primaryColor.name)-\(comparisonColor.name)" }
    let primaryColor: ColorInfo
    let comparisonColor: ColorInfo
    let learningNotes: String
    
    let category: ColorCategory
    
    var allColors: [ColorInfo] {
        [primaryColor, comparisonColor]
    }
    
    var difficultyLevel: DifficultyLevel {
        let deltaE = ColorDatabase.shared.calculateColorDifference(color1: primaryColor, color2: comparisonColor)
        
        // Adjusted thresholds to ensure beginner pairs exist
        if deltaE < 5 {
            return .expert      // Very similar colors (e.g., Gamboge vs Indian Yellow)
        } else if deltaE < 15 {
            return .advanced    // Similar colors with subtle differences
        } else if deltaE < 25 {
            return .intermediate // Moderately different colors
        } else {
            return .beginner    // Clearly different colors
        }
    }
}

struct HSBFilter {
    let hueRange: ClosedRange<Double>
    let saturationRange: ClosedRange<Double>
    let brightnessRange: ClosedRange<Double>
    
    init(hue: Double, saturation: Double, brightness: Double, tolerance: Double = 30.0) {
        // Create ranges with tolerance
        let hueMin = max(0, hue - tolerance)
        let hueMax = min(360, hue + tolerance)
        self.hueRange = hueMin...hueMax
        
        let satMin = max(0, saturation - 0.2)
        let satMax = min(1, saturation + 0.2)
        self.saturationRange = satMin...satMax
        
        let brightMin = max(0, brightness - 0.2)
        let brightMax = min(1, brightness + 0.2)
        self.brightnessRange = brightMin...brightMax
    }
}

enum ColorCategory: String, CaseIterable, Codable {
    case yellows = "Yellows"
    case blues = "Blues"
    case reds = "Reds"
    case greens = "Greens"
    case purples = "Purples"
    case oranges = "Oranges"
    case neutrals = "Neutrals"
    
    var emoji: String {
        switch self {
        case .yellows: return "🟡"
        case .blues: return "🔵"
        case .reds: return "🔴"
        case .greens: return "🟢"
        case .purples: return "🟣"
        case .oranges: return "🟠"
        case .neutrals: return "⚪"
        }
    }
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .yellow
        case .advanced: return .orange
        case .expert: return .red
        }
    }
    
    var starIcons: String {
        switch self {
        case .beginner: return "⭐"
        case .intermediate: return "⭐⭐"
        case .advanced: return "⭐⭐⭐"
        case .expert: return "⭐⭐⭐⭐"
        }
    }
}

enum ChallengeType: CaseIterable {
    case nameToColor  // Show color name, pick correct color
    case colorToName  // Show color, pick correct name
    
    var description: String {
        switch self {
        case .nameToColor: return "Which color is"
        case .colorToName: return "What is this color called?"
        }
    }
}

// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            // swiftlint:disable:next colon
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue:  Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
