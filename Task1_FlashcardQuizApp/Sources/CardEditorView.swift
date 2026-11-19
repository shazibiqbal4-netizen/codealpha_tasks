import SwiftUI

/// Whether the editor sheet is adding a new card or editing an existing one.
enum EditorMode: Identifiable {
    case add
    case edit(Flashcard)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let card): return card.id.uuidString
        }
    }

    var title: String {
        switch self {
        case .add: return "New Flashcard"
        case .edit: return "Edit Flashcard"
        }
    }
}

struct CardEditorView: View {
    let mode: EditorMode
    let onSave: (_ question: String, _ answer: String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var question: String
    @State private var answer: String

    init(mode: EditorMode, onSave: @escaping (_ question: String, _ answer: String) -> Void) {
        self.mode = mode
        self.onSave = onSave
        if case .edit(let card) = mode {
            _question = State(initialValue: card.question)
            _answer = State(initialValue: card.answer)
        } else {
            _question = State(initialValue: "")
            _answer = State(initialValue: "")
        }
    }

    private var canSave: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Question (front)") {
                    TextEditor(text: $question)
                        .frame(minHeight: 90)
                }
                Section("Answer (back)") {
                    TextEditor(text: $answer)
                        .frame(minHeight: 90)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(question.trimmingCharacters(in: .whitespacesAndNewlines),
                               answer.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
