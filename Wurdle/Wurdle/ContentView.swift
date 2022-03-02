import SwiftUI



struct ContentView: View {
    @ObservedObject var state = GuessState()

    var body: some View {
        ScrollView {
            VStack {
                Header()
                TextInput(text: $state.guess, onEnterPressed: {
                    state.checkCompleteGuess()
                })
                .opacity(0)
                LetterGrid(guess: state.guess, guesses: state.guesses)
                    .padding()
            }
        }
        .onChange(of: state.guess) { _ in
            state.validateGuess()
        }
    }
}

struct Header: View {
    var body: some View {
        VStack(spacing: 3) {
            HStack {
                Text("Wurdle".uppercased())
                    .font(.largeTitle)
                    .bold()
            }
            Rectangle().fill(Color.gray)
                .frame(height: 1)
        }
    }
}

struct TextInput: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    let onEnterPressed: () -> Void
    var body: some View {
        TextField("Word", text: $text)
            .textInputAutocapitalization(.characters)
            .keyboardType(.asciiCapable)
            .disableAutocorrection(true)
            .focused($isFocused)
            .onChange(of: isFocused, perform: { newFocus in
                if !newFocus {
                    onEnterPressed()
                    isFocused = true
                }
            })
            .task {
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC/4)
                isFocused = true
            }
    }
}

struct LetterGrid: View {
    let width = 5
    let height = 6
    
    let guess: String
    let guesses: [Guess]

    var body: some View {
        VStack {
            ForEach(0..<height, id: \.self) { row in
                HStack {
                    ForEach(0..<width, id: \.self) { col in
                        LetterView(letter: character(row: row, col: col))
                    }
                }
            }
        }
    }
    
    private func character(row: Int, col: Int) -> LetterGuess {
        let guess: Guess
        if row < guesses.count {
            guess = guesses[row]
        } else if row == guesses.count {
            guess = .inProgress(self.guess)
        } else {
            return .blank
        }
        guard col < guess.count else { return .blank }
        return guess[col]
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
