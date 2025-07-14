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
    @State private var showingPhotoPicker = false

    var body: some View {
        NavigationView {
            VStack {
                GameView(gameModel: gameModel)
                FooterView(
                    onHome: { gameModel.goToMenu() },
                    onSettings: { showingSettings = true },
                    onCatalog: { showingColorDictionary = true },
                    onCamera: { showingPhotoPicker = true }
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
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoColorPickerView()
            }
        }
    }
}

#Preview {
    ContentView()
}
