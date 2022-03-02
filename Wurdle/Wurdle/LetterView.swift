import SwiftUI

extension LetterStatus {
    var color: Color {
        switch self {
        case .notRevealed: return Color.black
        case .notInWord: return Color.gray
        case .misplaced: return Color(.displayP3, red: 0.79, green: 0.71, blue: 0.35)
        case .correct: return Color(.displayP3, red: 0.42, green: 0.67, blue: 0.39)
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
                    .stroke(letter.status.color, lineWidth: 2)
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
            .modifier(LetterStatusModifier(status: letter.status))
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

struct LetterStatusModifier: ViewModifier {
    let status: LetterStatus

    func body(content: Content) -> some View {
        Group {
            switch status {
            case .notRevealed:
                content
                    .background(Color.white)
                    .foregroundColor(Color.black)
            default:
                content
                    .background(status.color)
                    .foregroundColor(Color.white)
            }
        }
    }
}

#if DEBUG
struct LetterView_Preview: PreviewProvider {

    static var previews: some View {
        Group {
            LetterView(letter: .blank)
                .padding()

            LetterView(letter: .init(char: "A", status: .notRevealed))
                .padding()

            LetterView(letter: .init(char: "A", status: .notInWord))
                .padding()

            LetterView(letter: .init(char: "A", status: .misplaced))
                .padding()

            LetterView(letter: .init(char: "A", status: .correct))
                .padding()
        }
        .previewLayout(.fixed(width: 100, height: 100))
    }
}
#endif
