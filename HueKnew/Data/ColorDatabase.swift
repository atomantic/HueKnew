//
//  ColorDatabase.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import Foundation

// MARK: - Color Classification Constants
struct ColorThresholds {
    // Hue thresholds for temperature classification (0-360 degrees)
    static let coolHueStart: Double = 90
    static let coolHueEnd: Double = 270
    
    // Saturation thresholds (0.0-1.0)
    static let lowSaturationThreshold: Double = 0.33
    static let mediumSaturationThreshold: Double = 0.66
    
    // Brightness thresholds (0.0-1.0)
    static let lowBrightnessThreshold: Double = 0.33
    static let mediumBrightnessThreshold: Double = 0.66
}

// MARK: - JSON Color Structures
struct JSONColorData: Codable {
    let colors: [JSONColor]
    let comparisonTemplates: ComparisonTemplates

    enum CodingKeys: String, CodingKey {
        case colors
        case comparisonTemplates = "comparison_templates"
    }
}

struct JSONColor: Codable {
    let name: String
    let hex: String
    let category: String

    let description: String

    enum CodingKeys: String, CodingKey {
        case name, hex, category, description
    }
}

struct ComparisonTemplates: Codable {
    let temperature: TemperatureTemplates
    let saturation: SaturationTemplates
    let brightness: BrightnessTemplates
    let purity: PurityTemplates
    let undertones: UndertoneTemplates
}

struct TemperatureTemplates: Codable {
    let warmer: String
    let cooler: String
    let similar: String
}

struct SaturationTemplates: Codable {
    let moreSaturated: String
    let lessSaturated: String
    let similar: String

    enum CodingKeys: String, CodingKey {
        case moreSaturated = "more_saturated"
        case lessSaturated = "less_saturated"
        case similar
    }
}

struct BrightnessTemplates: Codable {
    let brighter: String
    let darker: String
    let similar: String
}

struct PurityTemplates: Codable {
    let purer: String
    let moreMuted: String
    let similar: String

    enum CodingKeys: String, CodingKey {
        case purer
        case moreMuted = "more_muted"
        case similar
    }
}

struct UndertoneTemplates: Codable {
    let different: String
    let similar: String
    let noneVsSome: String

    enum CodingKeys: String, CodingKey {
        case different, similar
        case noneVsSome = "none_vs_some"
    }
}

class ColorDatabase: ObservableObject {
    static let shared = ColorDatabase()

    private var jsonData: JSONColorData?
    private var colorPairs: [ColorPair] = []

    private init() {
        loadColorsFromJSON()
    }

    private func loadColorsFromJSON() {
        guard let url = Bundle.main.url(forResource: "colors", withExtension: "json") else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            jsonData = try JSONDecoder().decode(JSONColorData.self, from: data)
            generateColorPairs()
        } catch {
            // Optionally handle error
        }
    }

    private func generateColorPairs() {
        guard let jsonData = jsonData else { return }

        // Group colors by category for pairing
        let colorsByCategory = Dictionary(grouping: jsonData.colors) { $0.category }

        for (category, colors) in colorsByCategory {
            // Create pairs within each category
            for idx1 in 0..<colors.count {
                for idx2 in (idx1+1)..<colors.count {
                    let color1 = colors[idx1]
                    let color2 = colors[idx2]

                    let colorInfo1 = ColorInfo(
                        name: color1.name,
                        hexValue: color1.hex,
                        description: color1.description,
                        category: mapStringToCategory(color1.category)
                    )

                    let colorInfo2 = ColorInfo(
                        name: color2.name,
                        hexValue: color2.hex,
                        description: color2.description,
                        category: mapStringToCategory(color2.category)
                    )

                    let learningNotes = generateComparisonNotes(color1: color1, color2: color2)

                    let colorPair = ColorPair(
                        primaryColor: colorInfo1,
                        comparisonColor: colorInfo2,
                        learningNotes: learningNotes,
                        category: mapStringToCategory(category)
                    )

                    colorPairs.append(colorPair)
                }
            }
        }
    }

    private func generateComparisonNotes(color1: JSONColor, color2: JSONColor) -> String {
        guard let templates = jsonData?.comparisonTemplates else {
            return "\(color1.name) vs \(color2.name): Compare their unique characteristics."
        }

        let info1 = ColorInfo(name: color1.name, hexValue: color1.hex, description: color1.description, category: mapStringToCategory(color1.category))
        let info2 = ColorInfo(name: color2.name, hexValue: color2.hex, description: color2.description, category: mapStringToCategory(color2.category))

        var notes: [String] = []

        let temp1 = temperatureCategory(for: info1)
        let temp2 = temperatureCategory(for: info2)
        if temp1 != temp2 {
            let warmer = temp1 == "warm" ? info1.name : info2.name
            let cooler = temp1 == "cool" ? info1.name : info2.name
            notes.append(templates.temperature.warmer.replacingOccurrences(of: "{color1}", with: warmer).replacingOccurrences(of: "{color2}", with: cooler))
        }

        let sat1 = saturationLevel(for: info1)
        let sat2 = saturationLevel(for: info2)
        if sat1 != sat2 {
            let moreSaturated = sat1 == "high" ? info1.name : info2.name
            let lessSaturated = sat1 == "low" ? info1.name : info2.name
            notes.append(templates.saturation.moreSaturated.replacingOccurrences(of: "{color1}", with: moreSaturated).replacingOccurrences(of: "{color2}", with: lessSaturated))
        }

        let bright1 = brightnessLevel(for: info1)
        let bright2 = brightnessLevel(for: info2)
        if bright1 != bright2 {
            let brighter = bright1 == "bright" ? info1.name : info2.name
            let darker = bright1 == "dark" ? info1.name : info2.name
            notes.append(templates.brightness.brighter.replacingOccurrences(of: "{color1}", with: brighter).replacingOccurrences(of: "{color2}", with: darker))
        }

        return notes.joined(separator: " ")
    }

    private func mapStringToCategory(_ categoryString: String) -> ColorCategory {
        switch categoryString.lowercased() {
        case "reds": return .reds
        case "blues": return .blues
        case "greens": return .greens
        case "yellows": return .yellows
        case "oranges": return .oranges
        case "purples": return .purples
        case "neutrals": return .neutrals
        default: return .neutrals
        }
    }

    private func mapStringToDifficulty(_ difficultyString: String) -> DifficultyLevel {
        switch difficultyString.lowercased() {
        case "beginner": return .beginner
        case "intermediate": return .intermediate
        case "advanced": return .advanced
        case "expert": return .expert
        default: return .beginner
        }
    }

    private func temperatureCategory(for color: ColorInfo) -> String {
        let hue = color.hsbComponents.hue
        return (hue >= ColorThresholds.coolHueStart && hue <= ColorThresholds.coolHueEnd) ? "cool" : "warm"
    }

    private func saturationLevel(for color: ColorInfo) -> String {
        let sat = color.hsbComponents.saturation
        switch sat {
        case 0..<ColorThresholds.lowSaturationThreshold: return "low"
        case ColorThresholds.lowSaturationThreshold..<ColorThresholds.mediumSaturationThreshold: return "medium"
        default: return "high"
        }
    }

    private func brightnessLevel(for color: ColorInfo) -> String {
        let bright = color.hsbComponents.brightness
        switch bright {
        case 0..<ColorThresholds.lowBrightnessThreshold: return "dark"
        case ColorThresholds.lowBrightnessThreshold..<ColorThresholds.mediumBrightnessThreshold: return "medium"
        default: return "bright"
        }
    }

    func getColorPairs(for category: ColorCategory) -> [ColorPair] {
        colorPairs.filter { $0.category == category }
    }

    func getColorPairs(for difficulty: DifficultyLevel) -> [ColorPair] {
        let filteredPairs = colorPairs.filter { $0.difficultyLevel == difficulty }
        return filteredPairs
    }
    
    func getColorPairs(matching filter: HSBFilter) -> [ColorPair] {
        return colorPairs.filter { pair in
            let hsb1 = pair.primaryColor.hsbComponents
            let hsb2 = pair.comparisonColor.hsbComponents
            
            // Check if either color in the pair matches the filter
            let matches1 = filter.hueRange.contains(hsb1.hue) &&
                          filter.saturationRange.contains(hsb1.saturation) &&
                          filter.brightnessRange.contains(hsb1.brightness)
            
            let matches2 = filter.hueRange.contains(hsb2.hue) &&
                          filter.saturationRange.contains(hsb2.saturation) &&
                          filter.brightnessRange.contains(hsb2.brightness)
            
            return matches1 || matches2
        }
    }

    func getRandomColorPair() -> ColorPair? {
        colorPairs.randomElement()
    }

    func getRandomColorPair(excluding: ColorPair) -> ColorPair? {
        colorPairs.filter { $0.id != excluding.id }.randomElement()
    }

    func getAllColors() -> [ColorInfo] {
        // Get unique colors from the JSON data to avoid duplicates
        guard let jsonData = jsonData else { return [] }
        
        return jsonData.colors.map { jsonColor in
            ColorInfo(
                name: jsonColor.name,
                hexValue: jsonColor.hex,
                description: jsonColor.description,
                category: mapStringToCategory(jsonColor.category)
            )
        }
    }

    func getAllColorPairs() -> [ColorPair] {
        colorPairs
    }

    func getRandomColors(count: Int, excluding: ColorInfo) -> [ColorInfo] {
        let allColors = getAllColors().filter { $0.id != excluding.id }
        return Array(allColors.shuffled().prefix(count))
    }

    func getAvailableColors() -> [JSONColor] {
        return jsonData?.colors ?? []
    }

    func getComparisonTemplates() -> ComparisonTemplates? {
        return jsonData?.comparisonTemplates
    }
    
    func calculateColorDifference(color1: ColorInfo, color2: ColorInfo) -> Double {
        let hsb1 = color1.hsbComponents
        let hsb2 = color2.hsbComponents
        
        // Calculate hue difference (handling circular nature of hue)
        let hueDiff = min(abs(hsb1.hue - hsb2.hue), 360 - abs(hsb1.hue - hsb2.hue))
        let normalizedHueDiff = hueDiff / 360.0 // Normalize to 0-1
        
        // Calculate saturation and brightness differences
        let satDiff = abs(hsb1.saturation - hsb2.saturation)
        let brightDiff = abs(hsb1.brightness - hsb2.brightness)
        
        // Weighted combination that prioritizes hue differences
        // Hue is most important for color perception, then saturation, then brightness
        let weightedDifference = (normalizedHueDiff * 0.6) + (satDiff * 0.25) + (brightDiff * 0.15)
        
        // Convert to a 0-100 scale for easier threshold setting
        return weightedDifference * 100.0
    }
}

extension ColorPair {
    var difficultyLevel: DifficultyLevel {
        let deltaE = ColorDatabase.shared.calculateColorDifference(color1: primaryColor, color2: comparisonColor)
        
        // New thresholds based on 0-100 scale with better perceptual accuracy
        if deltaE < 5 {
            return .expert      // Very similar colors (e.g., Gamboge vs Indian Yellow)
        } else if deltaE < 15 {
            return .advanced    // Similar colors with subtle differences
        } else if deltaE < 35 {
            return .intermediate // Moderately different colors
        } else {
            return .beginner    // Clearly different colors
        }
    }
}
