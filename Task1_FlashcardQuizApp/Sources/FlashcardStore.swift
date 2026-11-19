import Foundation

/// Holds all flashcards and saves them to UserDefaults so they persist between launches.
final class FlashcardStore: ObservableObject {
    @Published private(set) var cards: [Flashcard] = []

    private let storageKey = "flashcards.v1"

    init() {
        load()
        if cards.isEmpty && !UserDefaults.standard.bool(forKey: "flashcards.seeded") {
            cards = [
                Flashcard(question: "What keyword declares a constant in Swift?", answer: "let"),
                Flashcard(question: "What keyword declares a variable in Swift?", answer: "var"),
                Flashcard(question: "Which framework is used to build declarative UIs on Apple platforms?", answer: "SwiftUI")
            ]
            UserDefaults.standard.set(true, forKey: "flashcards.seeded")
            save()
        }
    }

    // MARK: - CRUD

    func add(question: String, answer: String) {
        cards.append(Flashcard(question: question, answer: answer))
        save()
    }

    func update(_ card: Flashcard, question: String, answer: String) {
        guard let i = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[i].question = question
        cards[i].answer = answer
        save()
    }

    func delete(_ card: Flashcard) {
        cards.removeAll { $0.id == card.id }
        save()
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([Flashcard].self, from: data) else { return }
        cards = saved
    }
}
