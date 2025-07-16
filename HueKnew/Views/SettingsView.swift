//
//  SettingsView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingResetAlert = false
    @State private var showingVisionTest = false

    private static let versionKey = "CFBundleShortVersionString"
    private static let buildKey = "CFBundleVersion"

    private var versionString: String {
        let version = Bundle.main.infoDictionary?[Self.versionKey] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?[Self.buildKey] as? String ?? "1"
        return "\(version) (build \(build))"
    }
    
    let gameModel: GameModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("Audio & Feedback") {
                    Toggle("Sound Effects", isOn: $audioManager.soundEnabled)
                    Toggle("Vibration", isOn: $audioManager.vibrationEnabled)
                    
                    Button("Test Sound & Vibration") {
                        AudioManager.shared.playSuccessFeedback()
                    }
                    .foregroundColor(.blue)
                }
                
                Section("Game Progress") {
                    Button("Reset Progress") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }

                Section("Accessibility") {
                    Button("Color Vision Test") {
                        showingVisionTest = true
                    }
                    .foregroundColor(.blue)

                    if gameModel.hasColorVisionDeficiency {
                        Text("Color vision assistance enabled")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(versionString)
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
            .sheet(isPresented: $showingVisionTest) {
                ColorVisionTestView { result in
                    gameModel.setColorVisionDeficiency(result)
                }
            }
        }
    }
}

#Preview {
    SettingsView(gameModel: GameModel())
}
