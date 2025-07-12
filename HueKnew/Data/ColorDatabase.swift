//
//  ColorDatabase.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import Foundation

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
    let attributes: ColorAttributes
    let distinguishingFeatures: [String]

    enum CodingKeys: String, CodingKey {
        case name, hex, category, description, attributes
        case distinguishingFeatures = "distinguishing_features"
    }
}

struct ColorAttributes: Codable {
    let temperature: String
    let saturation: String
    let brightness: String
    let undertones: [String]
    let purity: String
    let transparency: String
    let historicalSignificance: String

    enum CodingKeys: String, CodingKey {
        case temperature, saturation, brightness, undertones, purity, transparency
        case historicalSignificance = "historical_significance"
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
            print("Could not find colors.json file")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            jsonData = try JSONDecoder().decode(JSONColorData.self, from: data)
            generateColorPairs()
        } catch {
            print("Error loading colors.json: \(error)")
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

        var notes: [String] = []

        // Temperature comparison
        if color1.attributes.temperature != color2.attributes.temperature {
            let warmer = color1.attributes.temperature == "warm" ? color1.name : color2.name
            let cooler = color1.attributes.temperature == "cool" ? color1.name : color2.name
            notes.append(templates.temperature.warmer.replacingOccurrences(of: "{color1}", with: warmer).replacingOccurrences(of: "{color2}", with: cooler))
        }

        // Saturation comparison
        if color1.attributes.saturation != color2.attributes.saturation {
            let moreSaturated = color1.attributes.saturation == "high" ? color1.name : color2.name
            let lessSaturated = color1.attributes.saturation == "low" ? color1.name : color2.name
            notes.append(templates.saturation.moreSaturated.replacingOccurrences(of: "{color1}", with: moreSaturated).replacingOccurrences(of: "{color2}", with: lessSaturated))
        }

        // Brightness comparison
        if color1.attributes.brightness != color2.attributes.brightness {
            let brighter = color1.attributes.brightness == "bright" ? color1.name : color2.name
            let darker = color1.attributes.brightness == "dark" ? color1.name : color2.name
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

    func getColorPairs(for category: ColorCategory) -> [ColorPair] {
        colorPairs.filter { $0.category == category }
    }

    func getColorPairs(for difficulty: DifficultyLevel) -> [ColorPair] {
        colorPairs.filter { $0.difficultyLevel == difficulty }
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
        let rgb1 = color1.rgbComponents
        let rgb2 = color2.rgbComponents
        
        let deltaL = pow(rgb1.red - rgb2.red, 2)
        let deltaA = pow(rgb1.green - rgb2.green, 2)
        let deltaB = pow(rgb1.blue - rgb2.blue, 2)
        
        return sqrt(deltaL + deltaA + deltaB)
    }
}

extension ColorPair {
    var difficultyLevel: DifficultyLevel {
        let deltaE = ColorDatabase.shared.calculateColorDifference(color1: primaryColor, color2: comparisonColor)
        
        if deltaE < 10 {
            return .expert
        } else if deltaE < 20 {
            return .advanced
        } else if deltaE < 40 {
            return .intermediate
        } else {
            return .beginner
        }
    }
}
