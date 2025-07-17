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
    @State private var activeView: ActiveView = .home

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
                        activeView = .home
                    },
                    onCamera: {
                        showingCameraPicker = true
                        activeView = .camera
                    },
                    onSettings: {
                        showingSettings = true
                        activeView = .settings
                    },
                    onCatalog: {
                        showingCameraPicker = false
                        showingColorDictionary = true
                        activeView = .catalog
                    },
                    showCamera: true,
                    activeView: $activeView
                )
                .safeAreaPadding(.bottom)
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                SettingsView(gameModel: gameModel)
                    .onDisappear { activeView = .home }
            }
            .sheet(isPresented: $showingColorDictionary) {
                ColorDictionaryView()
                    .onDisappear { activeView = .home }
            }
        }
    }
}

#Preview {
    ContentView()
}
