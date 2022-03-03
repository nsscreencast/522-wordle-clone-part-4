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

struct LetterView: View {
    var letter: LetterGuess = .blank
    @State private var filled: Bool

    init(letter: LetterGuess) {
        self.letter = letter
        filled = !letter.char.isWhitespace
    }

    private let scaleAmount: CGFloat = 1.2

    var body: some View {
        Color.clear
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .opacity(filled ? 0 : 1)
                    .animation(.none, value: filled)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.black, lineWidth: 2)
                    .scaleEffect(filled ? 1 : scaleAmount)
                    .opacity(filled ? 1 : 0)
            )
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Text(String(letter.char))
                    .font(.system(size: 100))
                    .fontWeight(.heavy)
                    .minimumScaleFactor(0.1)
                    .scaleEffect(filled ? 1 : scaleAmount)
                    .padding(2)
            )
            .onChange(of: letter, perform: { newLetter in
                withAnimation {
                    if letter.char.isWhitespace && !newLetter.char.isWhitespace {
                        filled = true
                    } else if !letter.char.isWhitespace && newLetter.char.isWhitespace {
                        filled = false
                    }
                }
            })
    }

    var strokeColor: Color {
        if letter.char.isWhitespace {
            return Color.gray.opacity(0.3)
        } else {
            return Color.black
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
