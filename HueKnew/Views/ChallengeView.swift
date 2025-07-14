//
//  ChallengeView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

struct ChallengeView: View {
    let colorPair: ColorPair
    let challengeType: ChallengeType
    let onAnswerSelected: (Bool) -> Void
    
    @State private var selectedAnswer: ColorInfo?
    @State private var showingResult = false
    @State private var showInlineIncorrect = false
    @State private var answerOptions: [ColorInfo] = []
    @State private var targetColor: ColorInfo?

    /// Delay before automatically advancing to the next challenge after
    /// showing the result.
    private let autoAdvanceDelay: TimeInterval = 1.5
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                VStack(spacing: 32) {
                    // Question section
                    questionSection
                    
                    // Answer options
                    answerOptionsSection
                    
                    // Submit or continue button
                    if showInlineIncorrect {
                        Button(action: { onAnswerSelected(false) }) {
                            Text("Continue")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 0.3), value: showInlineIncorrect)
                    } else if selectedAnswer != nil && !showingResult {
                        Button(action: submitAnswer) {
                            Text("Submit Answer")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 0.3), value: selectedAnswer)
                    }
                }
                
                Spacer()
            }
            .background(Color(.systemBackground))
            
            // Result overlay
            if showingResult {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Optional: dismiss on background tap
                    }
                
                VStack {
                    Spacer()
                    
                    resultSection
                        .padding(.horizontal)
                        .padding(.bottom, 50) // Add space for footer
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            setupChallenge()
        }
    }
    
    @ViewBuilder
    private var questionSection: some View {
        VStack(spacing: 16) {
            switch challengeType {
            case .nameToColor:
                // Show color name, ask to pick color
                VStack(spacing: 8) {

                    Text(targetColor?.name ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding()
                }
                
            case .colorToName:
                // Show color, ask to pick name
                VStack(spacing: 8) {
                    
                    Rectangle()
                        .fill(targetColor?.color ?? Color.gray)
                        .frame(height: 120)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.horizontal, 40)
                }
            }
        }
        .padding()
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var answerOptionsSection: some View {
        VStack(spacing: 16) {
            
            switch challengeType {
            case .nameToColor:
                // Show color swatches
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(answerOptions) { colorInfo in
                        ColorOptionCard(
                            colorInfo: colorInfo,
                            isSelected: selectedAnswer?.name == colorInfo.name,
                            showName: false,
                            borderColor: nil
                        ) {
                            selectedAnswer = colorInfo
                        }
                    }
                }
                .padding(.horizontal)
                
            case .colorToName:
                // Show color names
                VStack(spacing: 12) {
                    ForEach(answerOptions) { colorInfo in
                        NameOptionCard(
                            colorInfo: colorInfo,
                            isSelected: selectedAnswer?.name == colorInfo.name,
                            showSwatch: showInlineIncorrect,
                            borderColor: showInlineIncorrect ? borderColor(for: colorInfo) : nil,
                            showIncorrectIcon: showInlineIncorrect && selectedAnswer?.name == colorInfo.name
                        ) {
                            selectedAnswer = colorInfo
                        }
                        .disabled(showInlineIncorrect)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var resultSection: some View {
        // Determine if the user's answer was correct so it can be used both
        // in the view and when automatically progressing to the next challenge.
        let isCorrect = selectedAnswer?.name == targetColor?.name

        VStack(spacing: 16) {
            // Result indicator
            
            VStack(spacing: 8) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(isCorrect ? .green : .red)
                
                if !isCorrect {
                    VStack(spacing: 8) {
                        Text("The correct answer was:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if challengeType == .nameToColor {
                            // Show the correct color swatch
                            Rectangle()
                                .fill(targetColor?.color ?? Color.gray)
                                .frame(height: 60)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.green, lineWidth: 3)
                                )

                            Text(targetColor?.name ?? "")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            // Show which color user selected
                            if let selected = selectedAnswer {
                                Text("You chose: \(selected.name)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            // colorToName: highlight correct name and show swatches
                            Text(targetColor?.name ?? "")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(answerOptions) { option in
                                    ColorOptionCard(
                                        colorInfo: option,
                                        isSelected: false,
                                        showName: true,
                                        borderColor: borderColor(for: option)
                                    ) {
                                        // no action in result view
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
        }
        .animation(.easeInOut(duration: 0.5), value: showingResult)
        .onAppear {
            // Automatically move to the next challenge after a short delay.
            DispatchQueue.main.asyncAfter(deadline: .now() + autoAdvanceDelay) {
                onAnswerSelected(isCorrect)
            }
        }
    }
    
    private func setupChallenge() {
        showInlineIncorrect = false
        selectedAnswer = nil
        // Set target color (randomly pick one from the pair)
        targetColor = [colorPair.primaryColor, colorPair.comparisonColor].randomElement()
        
        // Create answer options
        var options = [targetColor!]
        
        // Add the other color from the pair
        let otherColor = targetColor?.name == colorPair.primaryColor.name ?
            colorPair.comparisonColor : colorPair.primaryColor
        options.append(otherColor)
        
        // Add 2 more random colors from the database
        let randomColors = ColorDatabase.shared.getRandomColors(count: 2, excluding: targetColor!)
        options.append(contentsOf: randomColors)
        
        // Shuffle the options
        answerOptions = options.shuffled()
    }
    
    private func submitAnswer() {
        let isCorrect = selectedAnswer?.name == targetColor?.name
        if challengeType == .colorToName && !isCorrect {
            showInlineIncorrect = true
        } else {
            showingResult = true
        }
    }

    private func borderColor(for option: ColorInfo) -> Color? {
        if option.name == targetColor?.name {
            return .green
        } else if option.name == selectedAnswer?.name {
            return .red
        } else {
            return nil
        }
    }
}

struct ColorOptionCard: View {
    let colorInfo: ColorInfo
    let isSelected: Bool
    let showName: Bool
    let borderColor: Color?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Rectangle()
                    .fill(colorInfo.color)
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor ?? (isSelected ? Color.blue : Color.clear), lineWidth: (borderColor != nil || isSelected) ? 3 : 0)
                    )
                    .cornerRadius(8)
                
                if showName {
                    Text(colorInfo.name)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NameOptionCard: View {
    let colorInfo: ColorInfo
    let isSelected: Bool
    let showSwatch: Bool
    let borderColor: Color?
    let showIncorrectIcon: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                if showSwatch {
                    Rectangle()
                        .fill(colorInfo.color)
                        .frame(width: 24, height: 24)
                        .cornerRadius(4)
                }
                Text(colorInfo.name)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if isSelected {
                    Image(systemName: showIncorrectIcon ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(showIncorrectIcon ? .red : .blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor ?? Color.clear, lineWidth: borderColor != nil ? 3 : 0)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ChallengeView(
        colorPair: ColorPair(
            primaryColor: ColorInfo(
                name: "Gamboge",
                hexValue: "#E49B0F",
                description: "A deep golden yellow with warm undertones",
                category: .yellows
            ),
            comparisonColor: ColorInfo(
                name: "Indian Yellow",
                hexValue: "#E3B505",
                description: "A rich, warm yellow with orange undertones",
                category: .yellows
            ),
            learningNotes: "Gamboge has more brown/amber undertones, while Indian Yellow is purer and brighter with orange hints.",
            category: .yellows
        ),
        challengeType: .nameToColor,
        onAnswerSelected: { isCorrect in
            print("Answer was \(isCorrect ? "correct" : "incorrect")")
        }
    )
}
