//
//  SettingsView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var showingResetAlert = false
    
    let gameModel: GameModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("Audio & Feedback") {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                    Toggle("Vibration", isOn: $vibrationEnabled)
                }
                
                Section("Game Progress") {
                    Button("Reset Progress") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://raw.githubusercontent.com/atomantic/HueKnew/refs/heads/main/PRIVACY_POLICY.md")!)
                        .foregroundColor(.blue)
                    
                    Link("Terms of Service", destination: URL(string: "https://raw.githubusercontent.com/atomantic/HueKnew/refs/heads/main/TERMS_OF_USE.md")!)
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset Progress", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    gameModel.resetProgress()
                }
            } message: {
                Text("This will reset all your game progress including score, level, streak, and mastered colors. This action cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView(gameModel: GameModel())
}
