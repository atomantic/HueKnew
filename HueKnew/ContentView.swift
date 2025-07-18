//
//  ContentView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var gameModel = GameModel()
    @State private var activeView: ActiveView = .home

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                switch activeView {
                case .camera:
                    CameraColorPickerView()
                case .catalog:
                    ColorDictionaryView()
                case .settings:
                    SettingsView(gameModel: gameModel)
                case .imagine:
                    ImagineView()
                case .home:
                    GameView(gameModel: gameModel)
                }

                FooterView(
                    onHome: {
                        activeView = .home
                        gameModel.goToMenu()
                    },
                    onCamera: {
                        activeView = .camera
                    },
                    onSettings: {
                        activeView = .settings
                    },
                    onCatalog: {
                        activeView = .catalog
                    },
                    onImagine: {
                        activeView = .imagine
                    },
                    showCamera: true,
                    activeView: $activeView
                )
                .safeAreaPadding(.bottom)
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
