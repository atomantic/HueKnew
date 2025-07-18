//
//  ColorDictionaryView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

struct ColorDictionaryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: ColorCategory? = nil
    @State private var sortOrder: SortOrder = .alphabetical
    
    private let colorDatabase = ColorDatabase.shared
    
    enum SortOrder: String, CaseIterable {
        case alphabetical = "Name"
        case category = "Category"
        case hue = "Hue"
        
        var systemImage: String {
            switch self {
            case .alphabetical: return "textformat.abc"
            case .category: return "folder"
            case .hue: return "paintbrush"
            }
        }
    }
    
    var filteredColors: [ColorInfo] {
        let allColors = colorDatabase.getAllColors()
        var filtered = allColors
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { color in
                color.name.lowercased().contains(searchText.lowercased()) ||
                color.description.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Sort
        switch sortOrder {
        case .alphabetical:
            filtered.sort { $0.name < $1.name }
        case .category:
            filtered.sort { color1, color2 in
                if color1.category == color2.category {
                    return color1.name < color2.name
                }
                return color1.category.rawValue < color2.category.rawValue
            }
        case .hue:
            filtered.sort { color1, color2 in
                let hue1 = color1.color.hue
                let hue2 = color2.color.hue
                if abs(hue1 - hue2) < 0.001 {
                    return color1.name < color2.name
                }
                return hue1 < hue2
            }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 0) {
                // Search and filter controls
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search colors...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Filter controls
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // Category filter
                            Menu {
                                Button("All Categories") {
                                    selectedCategory = nil
                                }
                                
                                ForEach(ColorCategory.allCases, id: \.self) { category in
                                    Button(category.emoji + " " + category.rawValue) {
                                        selectedCategory = category
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "folder")
                                    Text(selectedCategory?.rawValue ?? "All")
                                    Image(systemName: "chevron.down")
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            }
                            
                            // Sort order
                            Menu {
                                ForEach(SortOrder.allCases, id: \.self) { order in
                                    Button(action: { sortOrder = order }) {
                                        HStack {
                                            Image(systemName: order.systemImage)
                                            Text(order.rawValue)
                                            if sortOrder == order {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: sortOrder.systemImage)
                                    Text(sortOrder.rawValue)
                                    Image(systemName: "chevron.down")
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Results count
                    HStack {
                        Text("\(filteredColors.count) colors")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Color list
                List(filteredColors, id: \.name) { color in
                    NavigationLink(destination: ColorDetailView(color: color)) {
                        ColorListRow(color: color)
                    }
                }
                .listStyle(PlainListStyle())
        }
        .navigationTitle("Color Catalog")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ColorListRow: View {
    let color: ColorInfo
    
    var body: some View {
        HStack(spacing: 12) {
            // Color swatch
            Rectangle()
                .fill(color.color)
                .frame(width: 50, height: 50)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            // Color information
            VStack(alignment: .leading, spacing: 4) {
                Text(color.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(color.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(color.category.emoji + " " + color.category.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(color.hexValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// Extension to get hue from Color
extension Color {
    var hue: Double {
        guard let cgColor = self.cgColor else { return 0 }
        guard cgColor.colorSpace != nil else { return 0 }
        guard let components = cgColor.components else { return 0 }
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        let max = Swift.max(red, green, blue)
        let min = Swift.min(red, green, blue)
        let delta = max - min
        
        if delta == 0 {
            return 0
        }
        
        var hue: Double = 0
        
        if max == red {
            hue = ((green - blue) / delta).truncatingRemainder(dividingBy: 6)
        } else if max == green {
            hue = (blue - red) / delta + 2
        } else {
            hue = (red - green) / delta + 4
        }
        
        hue *= 60
        if hue < 0 {
            hue += 360
        }
        
        return hue
    }
}

#Preview {
    ColorDictionaryView()
}
