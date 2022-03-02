import SwiftUI

final class GuessState: ObservableObject {

    private let word = "DREAM"

    @Published var guess: String = ""
    @Published private(set) var guesses: [Guess] = []

    func validateGuess() {
        while guess.count > 5 {
            guess.removeLast()
        }

        guess = guess.trimmingCharacters(in: .letters.inverted)
    }

    func checkCompleteGuess() {
        if guess.count == 5 {
            let g = Guess.evaluate(guess, against: word)
            guesses.append(g)
            guess = ""
        }
    }
}
