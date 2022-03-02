enum LetterStatus: Equatable {
    case notRevealed
    case correct
    case misplaced
    case notInWord
}

struct LetterGuess: Equatable {
    let char: Character
    var status: LetterStatus = .notRevealed

    static var blank: Self {
        .init(char: " ")
    }
}

struct Guess: Equatable {
    let letters: [LetterGuess]

    var count: Int {
        letters.count
    }

    subscript(index: Int) -> LetterGuess {
        get {
            letters[index]
        }
    }

    static func inProgress(_ input: String) -> Self {
        .init(letters: input.map { char in
            .init(char: char, status: .notRevealed)
        })
    }

    static func evaluate(_ input: String, against word: String) -> Self {
        .init(letters: input.enumerated().map { (index, character) in
            let letterStatus: LetterStatus
            let wordIndex = word.index(word.startIndex, offsetBy: index)
            if word[wordIndex] == character {
                letterStatus = .correct
            } else if word.contains(character) {
                // Note: different from actual Wordle
                letterStatus = .misplaced
            } else {
                letterStatus = .notInWord
            }
            return .init(char: character, status: letterStatus)
        })
    }
}
