import SwiftUI

struct ImagineView: View {
    @StateObject private var viewModel = ImagineViewModel()
    @FocusState private var isInputActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Imagine")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(spacing: 2) {
                Text("Imagine colors in this scene:")
                Text(viewModel.currentEnvironment)
                    .font(.title3)
                    .bold()
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

            if !viewModel.isDone {
                VStack(spacing: 12) {
                    TextField("Enter color", text: $viewModel.inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isInputActive)
                        .onSubmit {
                            viewModel.addColor(viewModel.inputText)
                            viewModel.inputText = ""
                        }
                        .onChange(of: viewModel.inputText) { oldValue, newValue in
                            if newValue.contains(",") {
                                let parts = newValue.split(separator: ",")
                                parts.dropLast().forEach { part in viewModel.addColor(String(part)) }
                                viewModel.inputText = parts.last.map(String.init) ?? ""
                            }
                        }
                    
                    Button("Done") {
                        viewModel.handleDoneButton()
                        isInputActive = false
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.enteredColors.isEmpty)
                }
            }

            if !viewModel.enteredColors.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.enteredColors, id: \.self) { name in
                        ColorPill(name: name, info: viewModel.colorDatabase.color(named: name))
                    }
                }
            }

            if !viewModel.autocompleteSuggestions.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.autocompleteSuggestions, id: \.self) { suggestion in
                            Button(action: {
                                viewModel.enteredColors.append(suggestion)
                                viewModel.inputText = ""
                            }) {
                                Text(suggestion)
                                    .padding(.vertical, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .frame(maxHeight: 120)
                .background(Color(.systemGray6))
            }

            

            if viewModel.showResults {
                VStack(spacing: 16) {
                    if viewModel.suggestedColors.isEmpty {
                        VStack(spacing: 8) {
                            Text("🎉 Great job!")
                                .font(.title2)
                                .bold()
                            Text("You've named all the colors we could think of for this environment!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        Button("New Environment") {
                            viewModel.newEnvironment()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("More ideas:")
                                .font(.headline)
                                .foregroundColor(.primary)

                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(viewModel.suggestedColors, id: \.id) { info in
                                        ColorInfoPanel(colorInfo: info) {
                                            viewModel.selectedColorInfo = info
                                            viewModel.showColorDetail = true
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 300)
                        }
                    }

                    if !viewModel.unusualColors.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Interesting choices:")
                                .font(.subheadline)
                                .bold()
                            Text("You thought of some colors we didn't include: \(viewModel.unusualColors.joined(separator: ", "))")
                                .font(.footnote)
                                .foregroundColor(.orange)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button("Try Another Environment") {
                        viewModel.newEnvironment()
                    }
                    .buttonStyle(.bordered)
                }
            }

            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isInputActive = false
                }
            }
        }
        .onAppear {
            if viewModel.currentEnvironment.isEmpty {
                viewModel.currentEnvironment = viewModel.colorDatabase.availableEnvironments().randomElement() ?? "forest"
            }
        }
        .sheet(isPresented: $viewModel.showColorDetail) {
            if let colorInfo = viewModel.selectedColorInfo {
                ColorDetailView(color: colorInfo)
            }
        }
    }
}

struct ColorPill: View {
    let name: String
    let info: ColorInfo?

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(info?.color ?? Color.gray)
                .frame(width: 20, height: 20)
            Text(name)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
                .fixedSize()
        }
        .padding(6)
        .background(Color(.systemGray5))
        .clipShape(Capsule())
    }
}

#Preview {
    ImagineView()
}
