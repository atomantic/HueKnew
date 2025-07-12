//
//  FooterView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

struct FooterView: View {
    let onRestart: () -> Void
    let onPause: () -> Void
    let onSettings: () -> Void
    let isPaused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Control buttons
            HStack(spacing: 20) {
                // Restart button
                Button(action: onRestart) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                        Text("Restart")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Pause/Resume button
                Button(action: onPause) {
                    VStack(spacing: 4) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.title2)
                        Text(isPaused ? "Resume" : "Pause")
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Settings button
                Button(action: onSettings) {
                    VStack(spacing: 4) {
                        Image(systemName: "gear")
                            .font(.title2)
                        Text("Settings")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    FooterView(
        onRestart: { print("Restart tapped") },
        onPause: { print("Pause tapped") },
        onSettings: { print("Settings tapped") },
        isPaused: false
    )
    .padding()
}
