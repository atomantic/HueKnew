//
//  ContentView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var gameModel = GameModel()
    @State private var showingSettings = false
    @State private var showingColorDictionary = false
    @State private var showingCameraPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showingCameraPicker {
                    CameraColorPickerView()
                } else {
                    GameView(gameModel: gameModel)
                }
                FooterView(
                    onHome: {
                        showingCameraPicker = false
                        gameModel.goToMenu()
                    },
                    onCamera: { showingCameraPicker = true },
                    onSettings: { showingSettings = true },
                    onCatalog: {
                        showingCameraPicker = false
                        showingColorDictionary = true
                    },
                    showCamera: true
                )
                .safeAreaPadding(.bottom)
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                SettingsView(gameModel: gameModel)
            }
            .sheet(isPresented: $showingColorDictionary) {
                ColorDictionaryView()
            }
        }
    }
}

#Preview {
    ContentView()
}
