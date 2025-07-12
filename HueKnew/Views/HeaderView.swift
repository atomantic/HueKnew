//
//  HeaderView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

struct HeaderView: View {
    let score: Int
    let level: Int
    let currentStreak: Int
    let bestStreak: Int

    var body: some View {
        VStack(spacing: 8) {
            // App Title
            Text("Hue Knew")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            // Game Stats
            HStack {
                // Score
                VStack {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(score)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)

                // Level
                VStack {
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(level)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)

                // Current Streak
                VStack {
                    Text("Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currentStreak)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity)
                
                // Best Streak
                VStack {
                    Text("Best")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(bestStreak)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    HeaderView(
        score: 1250, 
        level: 3, 
        currentStreak: 8,
        bestStreak: 23
    )
    .padding()
}
