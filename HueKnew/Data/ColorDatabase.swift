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
        testDifficultyDistribution()
    }
    
    private func testDifficultyDistribution() {
        print("=== TESTING DIFFICULTY DISTRIBUTION ===")
        let allPairs = getAllColorPairs()
        print("Total pairs: \(allPairs.count)")
        
        var difficultyCounts: [DifficultyLevel: Int] = [:]
        var maxDifference = 0.0
        
        for pair in allPairs {
            let diff = calculateColorDifference(color1: pair.primaryColor, color2: pair.comparisonColor)
            maxDifference = max(maxDifference, diff)
            
            let level = pair.difficultyLevel
            difficultyCounts[level, default: 0] += 1
        }
        
        print("Max difference found: \(maxDifference)")
        print("Difficulty distribution:")
        for (level, count) in difficultyCounts.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            print("  \(level.rawValue): \(count) pairs")
        }
        
        // Check if we have any beginner pairs
        let beginnerPairs = allPairs.filter { $0.difficultyLevel == .beginner }
        print("Beginner pairs: \(beginnerPairs.count)")
        
        if beginnerPairs.isEmpty {
            print("ERROR: No beginner difficulty pairs found!")
            print("This explains why 1-star difficulty selection shows loading screen.")
        }
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
        let filteredPairs = colorPairs.filter { $0.difficultyLevel == difficulty }
        print("DEBUG: getColorPairs(for: \(difficulty.rawValue)) - Total pairs: \(colorPairs.count), Filtered pairs: \(filteredPairs.count)")
        
        // Debug: Show difficulty distribution
        let difficultyCounts = Dictionary(grouping: colorPairs) { $0.difficultyLevel }
        for (level, pairs) in difficultyCounts {
            print("DEBUG: \(level.rawValue): \(pairs.count) pairs")
        }
        
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
    
    // Debug method to test color differences
    func debugColorDifferences() {
        print("=== Color Difference Debug ===")
        
        // Test some known pairs
        let testPairs = [
            ("Gamboge", "#E49B0F", "Indian Yellow", "#E3B505"),
            ("Cadmium Yellow", "#FFF600", "Lemon Yellow", "#FFFF9F"),
            ("Prussian Blue", "#003153", "Navy Blue", "#000080"),
            ("Vermillion", "#E34234", "Cinnabar", "#E44D2E")
        ]
        
        for (name1, hex1, name2, hex2) in testPairs {
            let color1 = ColorInfo(name: name1, hexValue: hex1, description: "", category: .yellows)
            let color2 = ColorInfo(name: name2, hexValue: hex2, description: "", category: .yellows)
            let diff = calculateColorDifference(color1: color1, color2: color2)
            let level = ColorPair(primaryColor: color1, comparisonColor: color2, learningNotes: "", category: .yellows).difficultyLevel
            print("\(name1) vs \(name2): \(String(format: "%.2f", diff)) -> \(level.rawValue)")
        }
        
        // Test with actual color pairs from the database
        print("\n=== Actual Database Pairs ===")
        let allPairs = getAllColorPairs()
        let samplePairs = Array(allPairs.prefix(10))
        
        for pair in samplePairs {
            let diff = calculateColorDifference(color1: pair.primaryColor, color2: pair.comparisonColor)
            print("\(pair.primaryColor.name) vs \(pair.comparisonColor.name): \(String(format: "%.2f", diff)) -> \(pair.difficultyLevel.rawValue)")
        }
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
