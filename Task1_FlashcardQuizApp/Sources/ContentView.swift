import SwiftUI

struct ContentView: View {
    @StateObject private var store = FlashcardStore()
    @State private var index = 0
    @State private var showAnswer = false
    @State private var editorMode: EditorMode?
    @State private var showDeleteAlert = false

    private var currentCard: Flashcard? {
        store.cards.indices.contains(index) ? store.cards[index] : nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if let card = currentCard {
                    studyView(for: card)
                } else {
                    emptyState
                }
            }
            .padding()
            .navigationTitle("Flashcards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editorMode = .add
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add flashcard")
                }
            }
            .sheet(item: $editorMode) { mode in
                CardEditorView(mode: mode) { question, answer in
                    switch mode {
                    case .add:
                        store.add(question: question, answer: answer)
                        index = store.cards.count - 1   // jump to the new card
                        showAnswer = false
                    case .edit(let card):
                        store.update(card, question: question, answer: answer)
                    }
                }
            }
            .alert("Delete this flashcard?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { deleteCurrentCard() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This can't be undone.")
            }
        }
    }

    // MARK: - Study screen

    private func studyView(for card: Flashcard) -> some View {
        VStack(spacing: 20) {
            Text("Card \(index + 1) of \(store.cards.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            CardView(card: card, showAnswer: showAnswer)
                .frame(maxHeight: 320)

            Button {
                withAnimation(.easeInOut(duration: 0.4)) { showAnswer.toggle() }
            } label: {
                Text(showAnswer ? "Show Question" : "Show Answer")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)

            HStack(spacing: 12) {
                Button { go(to: index - 1) } label: {
                    Label("Previous", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .disabled(index == 0)

                Button { go(to: index + 1) } label: {
                    Label("Next", systemImage: "chevron.right")
                        .labelStyle(TrailingIconLabelStyle())
                        .frame(maxWidth: .infinity)
                }
                .disabled(index >= store.cards.count - 1)
            }
            .buttonStyle(.bordered)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    editorMode = .edit(card)
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.on.rectangle.slash")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("No flashcards yet")
                .font(.title3.bold())
            Text("Tap the + button to create your first card.")
                .foregroundStyle(.secondary)
            Button("Add Flashcard") { editorMode = .add }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Actions

    private func go(to newIndex: Int) {
        guard store.cards.indices.contains(newIndex) else { return }
        showAnswer = false
        index = newIndex
    }

    private func deleteCurrentCard() {
        guard let card = currentCard else { return }
        store.delete(card)
        showAnswer = false
        index = max(0, min(index, store.cards.count - 1))
    }
}

// MARK: - Card with flip animation

struct CardView: View {
    let card: Flashcard
    let showAnswer: Bool

    var body: some View {
        ZStack {
            face(label: "QUESTION", text: card.question, color: .blue)
                .opacity(showAnswer ? 0 : 1)

            face(label: "ANSWER", text: card.answer, color: .green)
                .opacity(showAnswer ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(showAnswer ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }

    private func face(label: String, text: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(color)
            ScrollView {
                Text(text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.4), lineWidth: 1.5)
        )
    }
}

/// Puts the icon after the title (used for the "Next" button).
struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.title
            configuration.icon
        }
    }
}

#Preview {
    ContentView()
}
