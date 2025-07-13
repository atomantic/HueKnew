//
//  AudioManager.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import Foundation
import AVFoundation
import UIKit

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var soundEnabled: Bool = false
    @Published var vibrationEnabled: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Settings Management
    
    func toggleSound() {
        soundEnabled.toggle()
        saveSettings()
    }
    
    func toggleVibration() {
        vibrationEnabled.toggle()
        saveSettings()
    }
    
    private func loadSettings() {
        soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        vibrationEnabled = UserDefaults.standard.bool(forKey: "vibrationEnabled")
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        UserDefaults.standard.set(vibrationEnabled, forKey: "vibrationEnabled")
    }
    
    // MARK: - Audio Playback
    
    func playSuccessSound() {
        guard soundEnabled else { return }
        
        // Create a simple success sound using system audio
        let systemSoundID = SystemSoundID(1322) // Success sound
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    // MARK: - Vibration
    
    func triggerSuccessVibration() {
        guard vibrationEnabled else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Combined Feedback
    
    func playSuccessFeedback() {
        playSuccessSound()
        triggerSuccessVibration()
    }
} 