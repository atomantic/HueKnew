//
//  ColorPair.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI
import Foundation

struct ColorInfo: Identifiable, Codable, Equatable {
    let id: UUID
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
            let r = Double((hexNumber & 0xFF0000) >> 16) / 255.0
            let g = Double((hexNumber & 0x00FF00) >> 8) / 255.0
            let b = Double(hexNumber & 0x0000FF) / 255.0
            return (r, g, b)
        }
        return (0, 0, 0)
    }
}

struct ColorPair: Identifiable, Codable {
    let id: UUID
    let primaryColor: ColorInfo
    let comparisonColor: ColorInfo
    let learningNotes: String
    let difficultyLevel: DifficultyLevel
    let category: ColorCategory
    
    var allColors: [ColorInfo] {
        [primaryColor, comparisonColor]
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
    case earth = "Earth Tones"
    case pastels = "Pastels"
    case jewel = "Jewel Tones"
    
    var emoji: String {
        switch self {
        case .yellows: return "🟡"
        case .blues: return "🔵"
        case .reds: return "🔴"
        case .greens: return "🟢"
        case .purples: return "🟣"
        case .oranges: return "🟠"
        case .neutrals: return "⚪"
        case .earth: return "🤎"
        case .pastels: return "🌸"
        case .jewel: return "💎"
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
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
