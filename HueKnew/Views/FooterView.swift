//
//  FooterView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

struct FooterView: View {
    let onHome: () -> Void
    let onCamera: () -> Void
    let onSettings: () -> Void
    let onCatalog: () -> Void
    
    var body: some View {
        HStack {
            // Home button
            Button(action: onHome) {
                VStack {
                    Image(systemName: "house.fill")
                        .font(.title2)
                    Text("Home")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            // Camera button
            Button(action: onCamera) {
                VStack {
                    Image(systemName: "camera")
                        .font(.title2)
                    Text("Camera")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            // Settings button
            Button(action: onSettings) {
                VStack {
                    Image(systemName: "gear")
                        .font(.title2)
                    Text("Settings")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            // Catalog button
            Button(action: onCatalog) {
                VStack {
                    Image(systemName: "book.fill")
                        .font(.title2)
                    Text("Catalog")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    FooterView(
        onHome: { print("Home tapped") },
        onCamera: { print("Camera tapped") },
        onSettings: { print("Settings tapped") },
        onCatalog: { print("Catalog tapped") }
    )
    .padding()
}
