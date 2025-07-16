//
//  ColorDatabase.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import Foundation

// MARK: - TSV Parsing Helper
struct TSVParser {
    static func parseTSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var inQuotes = false
        var i = 0
        
        while i < line.count {
            let char = line[line.index(line.startIndex, offsetBy: i)]
            
            if char == "\"" {
                if inQuotes && i + 1 < line.count && line[line.index(line.startIndex, offsetBy: i + 1)] == "\"" {
                    // Escaped quote
                    currentField += "\""
                    i += 2
                } else {
                    // Toggle quote state
                    inQuotes.toggle()
                    i += 1
                }
            } else if char == "\t" && !inQuotes {
                // End of field
                fields.append(currentField)
                currentField = ""
                i += 1
            } else {
                // Regular character
                currentField += String(char)
                i += 1
            }
        }
        
        // Add the last field
        fields.append(currentField)
        
        return fields
    }
}

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

// MARK: - TSV Color Structures
struct TSVColor {
    let hex: String
    let category: String
    let name: String
    let description: String
}

class ColorDatabase: ObservableObject {
    static let shared = ColorDatabase()

    private var tsvColors: [TSVColor] = []
    private var colorPairs: [ColorPair] = []
    private var closestColorCache: [String: ColorInfo] = [:]

    private init() {
        loadColorsFromTSV()
    }

    func loadColorsFromTSV() {
        guard let url = Bundle.main.url(forResource: "colors", withExtension: "tsv") else {
            Logger.error("Could not find colors.tsv in bundle")
            return
        }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            // Skip header line
            for line in lines.dropFirst() where !line.isEmpty {
                let components = TSVParser.parseTSVLine(line)
                guard components.count >= 4 else { continue }
                
                let tsvColor = TSVColor(
                    hex: components[0],
                    category: components[1],
                    name: components[2],
                    description: components[3]
                )
                tsvColors.append(tsvColor)
            }
            
            Logger.info("Successfully loaded \(tsvColors.count) colors from TSV")
            generateColorPairs()
        } catch {
            Logger.error("Failed to load colors from TSV: \(error.localizedDescription)")
        }
    }

    private func generateColorPairs() {
        guard !tsvColors.isEmpty else { return }

        // Group colors by category for pairing
        let colorsByCategory = Dictionary(grouping: tsvColors) { $0.category }

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

    private func generateComparisonNotes(color1: TSVColor, color2: TSVColor) -> String {
        let info1 = ColorInfo(name: color1.name, hexValue: color1.hex, description: color1.description, category: mapStringToCategory(color1.category))
        let info2 = ColorInfo(name: color2.name, hexValue: color2.hex, description: color2.description, category: mapStringToCategory(color2.category))

        let comparisons1 = getColorComparisons(color1: info1, color2: info2)
        let comparisons2 = getColorComparisons(color1: info2, color2: info1)
        
        var notes: [String] = []
        
        // Add first color's characteristics
        if !comparisons1.isEmpty {
            notes.append("\(info1.name): \(comparisons1.joined(separator: ", "))")
        }
        
        // Add second color's characteristics
        if !comparisons2.isEmpty {
            notes.append("\(info2.name): \(comparisons2.joined(separator: ", "))")
        }
        
        return notes.joined(separator: ". ")
    }
}

// MARK: - ColorDatabase Extensions
extension ColorDatabase {
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
        case "easy": return .easy
        case "intermediate": return .intermediate
        case "advanced": return .advanced
        default: return .easy
        }
    }
    
    func temperatureCategory(for color: ColorInfo) -> String {
        let hue = color.hsbComponents.hue
        return (hue >= ColorThresholds.coolHueStart && hue <= ColorThresholds.coolHueEnd) ? "cool" : "warm"
    }

    func saturationLevel(for color: ColorInfo) -> String {
        let sat = color.hsbComponents.saturation
        switch sat {
        case 0..<ColorThresholds.lowSaturationThreshold: return "low"
        case ColorThresholds.lowSaturationThreshold..<ColorThresholds.mediumSaturationThreshold: return "medium"
        default: return "high"
        }
    }

    func brightnessLevel(for color: ColorInfo) -> String {
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
    
    func getColorPair(containing colorInfo: ColorInfo) -> ColorPair? {
        return colorPairs.first { pair in
            pair.primaryColor.id == colorInfo.id || pair.comparisonColor.id == colorInfo.id
        }
    }

    func getAllColors() -> [ColorInfo] {
        // Get unique colors from the TSV data to avoid duplicates
        guard !tsvColors.isEmpty else { return [] }
        
        return tsvColors.map { tsvColor in
            ColorInfo(
                name: tsvColor.name,
                hexValue: tsvColor.hex,
                description: tsvColor.description,
                category: mapStringToCategory(tsvColor.category)
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

    func getMostSimilarColors(to color: ColorInfo, count: Int) -> [ColorInfo] {
        guard count > 0 else { return [] }

        var bestMatches: [(info: ColorInfo, diff: Double)] = []
        let candidates = getAllColors().filter { $0.id != color.id }

        for candidate in candidates {
            let diff = calculateColorDifference(color1: color, color2: candidate)

            if bestMatches.count < count {
                // Insert while maintaining ascending order by difference
                let index = bestMatches.firstIndex { diff < $0.diff } ?? bestMatches.count
                bestMatches.insert((candidate, diff), at: index)
            } else if let worst = bestMatches.last, diff < worst.diff {
                bestMatches.removeLast()
                let index = bestMatches.firstIndex { diff < $0.diff } ?? bestMatches.count
                bestMatches.insert((candidate, diff), at: index)
            }
        }

        return bestMatches.map { $0.info }
    }

    func getAvailableColors() -> [TSVColor] {
        return tsvColors
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
        // This creates a perceptually accurate difference score where:
        // - Low values (0-8): Very similar colors (Advanced difficulty)
        // - Medium values (8-25): Moderately similar colors (Intermediate difficulty)  
        // - High values (25+): Clearly different colors (Easy difficulty)
        let weightedDifference = (normalizedHueDiff * 0.6) + (satDiff * 0.25) + (brightDiff * 0.15)
        
        // Convert to a 0-100 scale for easier threshold setting
        return weightedDifference * 100.0
    }
    
    // MARK: - Shared Comparison Logic
    func getColorComparisons(color1: ColorInfo, color2: ColorInfo) -> [String] {
        let hsb1 = color1.hsbComponents
        let hsb2 = color2.hsbComponents
        
        Logger.debug("Comparing \(color1.name) (\(hsb1.hue), \(hsb1.saturation), \(hsb1.brightness)) with \(color2.name) (\(hsb2.hue), \(hsb2.saturation), \(hsb2.brightness))")
        
        var comparisons: [String] = []
        
        // Compare hue (color-specific descriptions)
        let hueDiff = hsb1.hue - hsb2.hue
        let normalizedHueDiff = abs(hueDiff) > 180 ? 360 - abs(hueDiff) : abs(hueDiff)
        if normalizedHueDiff > 0 {
            let colorDescription = getColorDescription(hue1: hsb1.hue, hue2: hsb2.hue)
            if !colorDescription.isEmpty {
                comparisons.append(colorDescription)
                Logger.debug("Added color description: \(colorDescription)")
            }
        }
        
        // Compare saturation (relative to color1)
        let satDiff = hsb1.saturation - hsb2.saturation
        if abs(satDiff) > 0.02 {
            if abs(satDiff) > 0.05 {
                comparisons.append(satDiff > 0 ? "More Saturated" : "Less Saturated")
            } else {
                comparisons.append(satDiff > 0 ? "Slightly More Saturated" : "Slightly Less Saturated")
            }
            Logger.debug("Added saturation comparison: \(satDiff)" )
        }
        
        // Compare brightness (relative to color1)
        let brightDiff = hsb1.brightness - hsb2.brightness
        if abs(brightDiff) > 0.02 {
            if abs(brightDiff) > 0.05 {
                comparisons.append(brightDiff > 0 ? "Brighter" : "Darker")
            } else {
                comparisons.append(brightDiff > 0 ? "Slightly Brighter" : "Slightly Darker")
            }
            Logger.debug("Added brightness comparison: \(brightDiff)")
        }

        // Vibrancy indicator
        if satDiff < -0.05 && brightDiff < -0.02 {
            comparisons.append("More Muted")
        } else if satDiff > 0.05 && brightDiff > 0.02 {
            comparisons.append("More Vibrant")
        }
        Logger.debug("Final comparisons for \(color1.name): \(comparisons)")
        return comparisons
    }
    
    private func getColorDescription(hue1: Double, hue2: Double) -> String {
        let hueDiff = hue1 - hue2
        let normalizedHueDiff = abs(hueDiff) > 180 ? 360 - abs(hueDiff) : abs(hueDiff)
        
        // Show color descriptions for any difference
        guard normalizedHueDiff > 0 else { return "" }
        
        // Define hue ranges for primary and secondary colors
        let redRange = 350.0...360.0
        let redRange2 = 0.0...10.0
        let orangeRange = 10.0...40.0
        let yellowRange = 40.0...75.0
        let greenRange = 75.0...165.0
        let blueRange = 165.0...255.0
        let purpleRange = 255.0...285.0
        let magentaRange = 285.0...350.0
        
        func getColorName(for hue: Double) -> String {
            let normalizedHue = hue < 0 ? hue + 360 : hue
            
            if redRange.contains(normalizedHue) || redRange2.contains(normalizedHue) {
                return "red"
            } else if orangeRange.contains(normalizedHue) {
                return "orange"
            } else if yellowRange.contains(normalizedHue) {
                return "yellow"
            } else if greenRange.contains(normalizedHue) {
                return "green"
            } else if blueRange.contains(normalizedHue) {
                return "blue"
            } else if purpleRange.contains(normalizedHue) {
                return "purple"
            } else if magentaRange.contains(normalizedHue) {
                return "magenta"
            } else {
                return "red" // Default for edge cases
            }
        }
        
        let color1 = getColorName(for: hue1)
        let color2 = getColorName(for: hue2)

        let adjustedDiff = hueDiff > 180 ? hueDiff - 360 : (hueDiff < -180 ? hueDiff + 360 : hueDiff)

        if color1 != color2 {
            return adjustedDiff > 0 ? "More \(color1.capitalized)" : "Less \(color1.capitalized)"
        } else {
            guard abs(adjustedDiff) > 1 else { return "" }
            let neighbor = adjacentColorName(for: color1, direction: adjustedDiff)
            if abs(adjustedDiff) < 5 {
                return "Hint of \(neighbor.capitalized)"
            } else {
                return "More \(neighbor.capitalized)"
            }
        }
    }
    private func adjacentColorName(for color: String, direction: Double) -> String {
        let order = ["red", "orange", "yellow", "green", "blue", "purple", "magenta", "red"]
        guard let index = order.firstIndex(of: color) else { return color }
        if direction > 0 {
            return order[index + 1]
        } else {
            return order[index == 0 ? order.count - 2 : index - 1]
        }
    }

    func closestColor(hue: Double, saturation: Double, brightness: Double) -> ColorInfo? {
        let key = String(format: "%.2f-%.2f-%.2f", hue, saturation, brightness)
        if let cached = closestColorCache[key] {
            return cached
        }

        var best: ColorInfo?
        var bestDiff = Double.greatestFiniteMagnitude
        for color in getAllColors() {
            let hsb = color.hsbComponents
            let diff = calculateColorDifference(hsb1: (hue, saturation, brightness), hsb2: hsb)
            if diff < bestDiff {
                bestDiff = diff
                best = color
            }
        }

        if let best {
            closestColorCache[key] = best
        }
        return best
    }

    private func calculateColorDifference(hsb1: (hue: Double, saturation: Double, brightness: Double), hsb2: (hue: Double, saturation: Double, brightness: Double)) -> Double {
        let hueDiff = min(abs(hsb1.hue - hsb2.hue), 360 - abs(hsb1.hue - hsb2.hue))
        let normalizedHueDiff = hueDiff / 360.0
        let satDiff = abs(hsb1.saturation - hsb2.saturation)
        let brightDiff = abs(hsb1.brightness - hsb2.brightness)
        let weightedDifference = (normalizedHueDiff * 0.6) + (satDiff * 0.25) + (brightDiff * 0.15)
        return weightedDifference * 100.0
    }
}

extension ColorPair {
    var difficultyLevel: DifficultyLevel {
        let deltaE = ColorDatabase.shared.calculateColorDifference(color1: primaryColor, color2: comparisonColor)
        
        // Improved thresholds based on color similarity
        // Colors that are very similar (low deltaE) are more advanced
        // Colors that are very different (high deltaE) are easier
        if deltaE < 8 {
            return .advanced      // Very similar colors (e.g., Gamboge vs Indian Yellow)
        } else if deltaE < 25 {
            return .intermediate  // Moderately similar colors
        } else {
            return .easy          // Clearly different colors
        }
    }
}
