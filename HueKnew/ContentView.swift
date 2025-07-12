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

    var body: some View {
        NavigationView {
            VStack {
                GameView(gameModel: gameModel)
                FooterView(
                    onHome: { gameModel.goToMenu() },
                    onSettings: { showingSettings = true },
                    onCatalog: { showingColorDictionary = true }
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
