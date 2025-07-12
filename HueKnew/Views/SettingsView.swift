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
    @State private var gameDuration = 60.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Game Settings") {
                    HStack {
                        Text("Game Duration")
                        Spacer()
                        Text("\(Int(gameDuration)) seconds")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $gameDuration, in: 30...120, step: 15)
                        .accentColor(.blue)
                }
                
                Section("Audio & Feedback") {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                    Toggle("Vibration", isOn: $vibrationEnabled)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                        .foregroundColor(.blue)
                    
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
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
        }
    }
}

#Preview {
    SettingsView()
}
