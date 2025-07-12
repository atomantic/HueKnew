//
//  ColorDetailView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

struct ColorDetailView: View {
    let color: ColorInfo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Color swatch
                Rectangle()
                    .fill(color.color)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.top)
                
                // Color details
                VStack(alignment: .leading, spacing: 8) {
                    Text(color.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("Category:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(color.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Hex Value:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(color.hexValue)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    Text("Description:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(color.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle(color.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    if let sampleColor = ColorDatabase.shared.getAllColors().first {
        ColorDetailView(color: sampleColor)
    }
}
