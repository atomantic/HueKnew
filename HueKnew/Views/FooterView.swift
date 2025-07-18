//
//  FooterView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

enum ActiveView {
    case home, camera, settings, catalog, imagine
}

struct FooterView: View {
    let onHome: () -> Void
    let onCamera: () -> Void
    let onSettings: () -> Void
    let onCatalog: () -> Void
    let onImagine: () -> Void
    var showCamera: Bool = true
    @Binding var activeView: ActiveView
    
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
            .foregroundColor(activeView == .home ? .blue : .primary)

            Spacer()

            if showCamera {
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
                .foregroundColor(activeView == .camera ? .blue : .primary)

                Spacer()
            }

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
            .foregroundColor(activeView == .catalog ? .blue : .primary)

            Spacer()

            // Imagine button
            Button(action: onImagine) {
                VStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                    Text("Imagine")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(activeView == .imagine ? .blue : .primary)

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
            .foregroundColor(activeView == .settings ? .blue : .primary)
        }
        .padding(.top, 12)
        .padding(.bottom, 6)
        .background(Color(.systemGray6))
    }
}

#Preview {
    FooterView(
        onHome: { print("Home tapped") },
        onCamera: { print("Camera tapped") },
        onSettings: { print("Settings tapped") },
        onCatalog: { print("Catalog tapped") },
        onImagine: {},
        showCamera: true,
        activeView: .constant(.home)
    )
    .padding()
}
