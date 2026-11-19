import Foundation

/// A single flashcard: question on the front, answer on the back.
struct Flashcard: Identifiable, Codable, Equatable {
    var id = UUID()
    var question: String
    var answer: String
}
