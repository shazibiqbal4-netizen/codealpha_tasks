import SwiftUI
import AVFoundation

// MARK: - App entry point

@main
struct LinguaLearnApp: App {
    @StateObject private var progress = ProgressStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(progress)
        }
    }
}

// MARK: - Models

enum Language: String, CaseIterable, Identifiable {
    case spanish = "Spanish"
    case french = "French"
    case german = "German"

    var id: String { rawValue }

    var flag: String {
        switch self {
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        }
    }

    /// Voice used for text-to-speech pronunciation.
    var speechCode: String {
        switch self {
        case .spanish: return "es-ES"
        case .french: return "fr-FR"
        case .german: return "de-DE"
        }
    }
}

enum Category: String, CaseIterable, Identifiable {
    case vocabulary = "Vocabulary"
    case phrases = "Phrases"
    case grammar = "Grammar"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .vocabulary: return "character.book.closed.fill"
        case .phrases: return "bubble.left.and.bubble.right.fill"
        case .grammar: return "list.bullet.rectangle.fill"
        }
    }
}

struct Entry: Identifiable, Hashable {
    let id: String
    let category: Category
    let english: String
    let translation: String
    let pronunciation: String
    let note: String?
}

// MARK: - Lesson content

enum Content {
    static func entries(for language: Language) -> [Entry] {
        switch language {
        case .spanish: return build(language, spanishVocab, spanishPhrases, spanishGrammar)
        case .french: return build(language, frenchVocab, frenchPhrases, frenchGrammar)
        case .german: return build(language, germanVocab, germanPhrases, germanGrammar)
        }
    }

    // Each row: [English, Translation, Pronunciation, optional note]
    private static func build(_ language: Language,
                              _ vocab: [[String]],
                              _ phrases: [[String]],
                              _ grammar: [[String]]) -> [Entry] {
        func make(_ category: Category, _ rows: [[String]]) -> [Entry] {
            rows.map { r in
                Entry(
                    id: "\(language.rawValue)|\(category.rawValue)|\(r[0])",
                    category: category,
                    english: r[0],
                    translation: r[1],
                    pronunciation: r[2],
                    note: r.count > 3 ? r[3] : nil
                )
            }
        }
        return make(.vocabulary, vocab) + make(.phrases, phrases) + make(.grammar, grammar)
    }

    // MARK: Spanish

    private static let spanishVocab: [[String]] = [
        ["Hello", "Hola", "OH-lah"],
        ["Goodbye", "Adiós", "ah-DYOHS"],
        ["Thank you", "Gracias", "GRAH-syahs"],
        ["Please", "Por favor", "por fah-VOR"],
        ["Water", "Agua", "AH-gwah"],
        ["Food", "Comida", "koh-MEE-dah"],
        ["House", "Casa", "KAH-sah"],
        ["Friend", "Amigo", "ah-MEE-goh"],
        ["Book", "Libro", "LEE-broh"],
        ["Cat", "Gato", "GAH-toh"],
        ["Dog", "Perro", "PEH-rroh"],
        ["Today", "Hoy", "oy"]
    ]

    private static let spanishPhrases: [[String]] = [
        ["How are you?", "¿Cómo estás?", "KOH-moh es-TAHS"],
        ["What is your name?", "¿Cómo te llamas?", "KOH-moh teh YAH-mahs"],
        ["Nice to meet you.", "Mucho gusto.", "MOO-choh GOOS-toh"],
        ["Where is the bathroom?", "¿Dónde está el baño?", "DOHN-deh es-TAH el BAH-nyoh"],
        ["How much does it cost?", "¿Cuánto cuesta?", "KWAHN-toh KWES-tah"],
        ["I don't understand.", "No entiendo.", "noh en-TYEN-doh"],
        ["Good morning", "Buenos días", "BWEH-nohs DEE-ahs"],
        ["Good night", "Buenas noches", "BWEH-nahs NOH-chehs"]
    ]

    private static let spanishGrammar: [[String]] = [
        ["I am a student.", "Yo soy estudiante.", "yoh soy es-too-DYAHN-teh",
         "Use 'ser' (soy) for identity and permanent traits."],
        ["I am tired.", "Estoy cansado.", "es-TOY kahn-SAH-doh",
         "Use 'estar' (estoy) for feelings and temporary states."],
        ["I have a book.", "Tengo un libro.", "TEN-goh oon LEE-broh",
         "'Tener' (to have): yo tengo."],
        ["She eats an apple.", "Ella come una manzana.", "EH-yah KOH-meh OO-nah mahn-SAH-nah",
         "-er verbs: the he/she form ends in -e."],
        ["The red house", "La casa roja", "lah KAH-sah ROH-hah",
         "Adjectives usually come after the noun and match its gender."],
        ["I like coffee.", "Me gusta el café.", "meh GOOS-tah el kah-FEH",
         "'Me gusta' literally means 'it pleases me'."]
    ]

    // MARK: French

    private static let frenchVocab: [[String]] = [
        ["Hello", "Bonjour", "bohn-ZHOOR"],
        ["Goodbye", "Au revoir", "oh ruh-VWAR"],
        ["Thank you", "Merci", "mehr-SEE"],
        ["Please", "S'il vous plaît", "seel voo PLEH"],
        ["Water", "L'eau", "loh"],
        ["Bread", "Le pain", "luh PAN"],
        ["House", "La maison", "lah meh-ZOHN"],
        ["Friend", "L'ami", "lah-MEE"],
        ["Book", "Le livre", "luh LEE-vruh"],
        ["Cat", "Le chat", "luh SHAH"],
        ["Dog", "Le chien", "luh SHYAN"],
        ["Today", "Aujourd'hui", "oh-zhoor-DWEE"]
    ]

    private static let frenchPhrases: [[String]] = [
        ["How are you?", "Comment allez-vous ?", "koh-mahn tah-lay VOO"],
        ["What is your name?", "Comment vous appelez-vous ?", "koh-mahn voo zah-play VOO"],
        ["Nice to meet you.", "Enchanté.", "ahn-shahn-TAY"],
        ["Where are the toilets?", "Où sont les toilettes ?", "oo sohn lay twah-LET"],
        ["How much is it?", "Combien ça coûte ?", "kohm-BYAN sah KOOT"],
        ["I don't understand.", "Je ne comprends pas.", "zhuh nuh kohm-PRAHN pah"],
        ["Good evening", "Bonsoir", "bohn-SWAR"],
        ["Good night", "Bonne nuit", "bun NWEE"]
    ]

    private static let frenchGrammar: [[String]] = [
        ["I am a student.", "Je suis étudiant.", "zhuh swee ay-too-DYAHN",
         "'Être' (to be): je suis."],
        ["I have a book.", "J'ai un livre.", "zhay uhn LEE-vruh",
         "'Avoir' (to have): j'ai."],
        ["She eats an apple.", "Elle mange une pomme.", "el MAHNZH oon POM",
         "-er verbs: the he/she form ends in -e."],
        ["We speak French.", "Nous parlons français.", "noo par-LOHN frahn-SAY",
         "The 'nous' form ends in -ons."],
        ["The red house", "La maison rouge", "lah meh-ZOHN ROOZH",
         "Adjectives usually come after the noun."],
        ["I like coffee.", "J'aime le café.", "zhem luh kah-FAY",
         "'Aimer' + the definite article to talk about likes."]
    ]

    // MARK: German

    private static let germanVocab: [[String]] = [
        ["Hello", "Hallo", "HAH-loh"],
        ["Goodbye", "Auf Wiedersehen", "owf VEE-der-zay-en"],
        ["Thank you", "Danke", "DAHN-kuh"],
        ["Please", "Bitte", "BIT-uh"],
        ["Water", "Das Wasser", "dahs VAH-ser"],
        ["Bread", "Das Brot", "dahs BROHT"],
        ["House", "Das Haus", "dahs HOWS"],
        ["Friend", "Der Freund", "dair FROYNT"],
        ["Book", "Das Buch", "dahs BOOKH"],
        ["Cat", "Die Katze", "dee KAHT-suh"],
        ["Dog", "Der Hund", "dair HOONT"],
        ["Today", "Heute", "HOY-tuh"]
    ]

    private static let germanPhrases: [[String]] = [
        ["How are you?", "Wie geht's?", "vee GAYTS"],
        ["What is your name?", "Wie heißt du?", "vee HYST doo"],
        ["Nice to meet you.", "Freut mich.", "FROYT mikh"],
        ["Where is the toilet?", "Wo ist die Toilette?", "voh ist dee toy-LET-uh"],
        ["How much does it cost?", "Wie viel kostet das?", "vee FEEL KOS-tet dahs"],
        ["I don't understand.", "Ich verstehe nicht.", "ikh fair-SHTAY-uh nikht"],
        ["Good morning", "Guten Morgen", "GOO-ten MOR-gen"],
        ["Good night", "Gute Nacht", "GOO-tuh NAKHT"]
    ]

    private static let germanGrammar: [[String]] = [
        ["I am a student.", "Ich bin Student.", "ikh bin shtoo-DENT",
         "'Sein' (to be): ich bin. No article is used for professions."],
        ["I have a book.", "Ich habe ein Buch.", "ikh HAH-buh yn BOOKH",
         "'Haben' (to have): ich habe."],
        ["She eats an apple.", "Sie isst einen Apfel.", "zee ist Y-nen AHP-fel",
         "Masculine nouns take 'einen' when they are the object."],
        ["We speak German.", "Wir sprechen Deutsch.", "veer SHPRE-khen DOYCH",
         "The 'wir' form ends in -en."],
        ["The red house", "Das rote Haus", "dahs ROH-tuh HOWS",
         "Adjectives take an ending when they stand before a noun."],
        ["I like coffee.", "Ich mag Kaffee.", "ikh MAHK KAH-fay",
         "'Mögen' (to like): ich mag."]
    ]
}

// MARK: - Progress storage (local, UserDefaults)

final class ProgressStore: ObservableObject {
    @Published private(set) var learned: Set<String> = []
    @Published private(set) var bestScores: [String: Int] = [:]

    private let learnedKey = "progress.learned.v1"
    private let scoresKey = "progress.scores.v1"

    init() {
        learned = Set(UserDefaults.standard.stringArray(forKey: learnedKey) ?? [])
        bestScores = (UserDefaults.standard.dictionary(forKey: scoresKey) as? [String: Int]) ?? [:]
    }

    func isLearned(_ entry: Entry) -> Bool {
        learned.contains(entry.id)
    }

    func toggleLearned(_ entry: Entry) {
        if learned.contains(entry.id) {
            learned.remove(entry.id)
        } else {
            learned.insert(entry.id)
        }
        save()
    }

    func markLearned(_ entry: Entry) {
        learned.insert(entry.id)
        save()
    }

    func recordScore(_ percent: Int, key: String) {
        if percent > (bestScores[key] ?? -1) {
            bestScores[key] = percent
            save()
        }
    }

    func bestScore(for key: String) -> Int? {
        bestScores[key]
    }

    private func save() {
        UserDefaults.standard.set(Array(learned), forKey: learnedKey)
        UserDefaults.standard.set(bestScores, forKey: scoresKey)
    }
}

func scoreKey(language: Language, category: Category?) -> String {
    let name = category?.rawValue ?? "Mixed"
    return "\(language.rawValue)|\(name)"
}

// MARK: - Pronunciation (text-to-speech)

final class Speaker {
    static let shared = Speaker()
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String, language: Language) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.speechCode)
        utterance.rate = 0.45
        synthesizer.speak(utterance)
    }
}

// MARK: - Home

struct HomeView: View {
    @EnvironmentObject var progress: ProgressStore
    @AppStorage("selectedLanguage") private var languageRaw = Language.spanish.rawValue

    private var language: Language {
        Language(rawValue: languageRaw) ?? .spanish
    }

    var body: some View {
        let entries = Content.entries(for: language)
        let learnedCount = entries.filter { progress.isLearned($0) }.count

        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(language.flag) Learning \(language.rawValue)")
                            .font(.title3.bold())
                        ProgressView(value: Double(learnedCount), total: Double(max(entries.count, 1)))
                            .tint(.green)
                        Text("\(learnedCount) of \(entries.count) items learned")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Today") {
                    NavigationLink {
                        DailyLessonView(language: language)
                    } label: {
                        Label("Daily Lesson", systemImage: "sun.max.fill")
                    }
                }

                Section("Flashcards") {
                    ForEach(Category.allCases) { category in
                        NavigationLink {
                            FlashcardsView(language: language, category: category)
                        } label: {
                            Label(category.rawValue, systemImage: category.icon)
                        }
                    }
                }

                Section("Quizzes") {
                    ForEach(Category.allCases) { category in
                        NavigationLink {
                            QuizView(language: language, category: category)
                        } label: {
                            quizRow(title: category.rawValue, icon: category.icon,
                                    key: scoreKey(language: language, category: category))
                        }
                    }
                    NavigationLink {
                        QuizView(language: language, category: nil)
                    } label: {
                        quizRow(title: "Mixed Test", icon: "shuffle",
                                key: scoreKey(language: language, category: nil))
                    }
                }
            }
            .navigationTitle("LinguaLearn")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Language", selection: $languageRaw) {
                            ForEach(Language.allCases) { l in
                                Text("\(l.flag) \(l.rawValue)").tag(l.rawValue)
                            }
                        }
                    } label: {
                        Label(language.rawValue, systemImage: "globe")
                    }
                }
            }
        }
    }

    private func quizRow(title: String, icon: String, key: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            if let best = progress.bestScore(for: key) {
                Text("Best \(best)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Daily lesson

struct DailyLessonView: View {
    let language: Language
    @EnvironmentObject var progress: ProgressStore

    /// Five items that change every day.
    private var lesson: [Entry] {
        let pool = Content.entries(for: language)
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let start = (day * 5) % max(pool.count, 1)
        return (0..<5).map { pool[(start + $0) % pool.count] }
    }

    var body: some View {
        List {
            Section {
                ForEach(lesson) { entry in
                    lessonRow(entry)
                }
            } header: {
                Text(Date().formatted(date: .complete, time: .omitted))
            } footer: {
                Text("Tap the speaker to hear it, and the check mark when you've learned it.")
            }
        }
        .navigationTitle("Daily Lesson")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func lessonRow(_ entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.category.rawValue.uppercased())
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text(entry.english)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(entry.translation)
                .font(.title2.bold())
            Text(entry.pronunciation)
                .font(.callout.italic())
                .foregroundStyle(.blue)
            if let note = entry.note {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 20) {
                Button {
                    Speaker.shared.speak(entry.translation, language: language)
                } label: {
                    Label("Listen", systemImage: "speaker.wave.2.fill")
                }

                Button {
                    progress.toggleLearned(entry)
                } label: {
                    Label(progress.isLearned(entry) ? "Learned" : "Mark learned",
                          systemImage: progress.isLearned(entry) ? "checkmark.circle.fill" : "circle")
                }
                .tint(progress.isLearned(entry) ? .green : .accentColor)
            }
            .buttonStyle(.borderless)
            .font(.subheadline)
            .padding(.top, 4)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Flashcards

struct FlashcardsView: View {
    let language: Language
    let category: Category

    @EnvironmentObject var progress: ProgressStore
    @State private var index = 0
    @State private var flipped = false

    private var cards: [Entry] {
        Content.entries(for: language).filter { $0.category == category }
    }

    var body: some View {
        let list = cards
        let card = list[min(index, list.count - 1)]

        VStack(spacing: 18) {
            Text("Card \(index + 1) of \(list.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            FlipCard(entry: card, flipped: flipped)
                .frame(maxHeight: 320)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.4)) { flipped.toggle() }
                }

            Button {
                withAnimation(.easeInOut(duration: 0.4)) { flipped.toggle() }
            } label: {
                Text(flipped ? "Show English" : "Show Translation")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)

            HStack(spacing: 12) {
                Button { go(to: index - 1, count: list.count) } label: {
                    Label("Previous", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .disabled(index == 0)

                Button {
                    Speaker.shared.speak(card.translation, language: language)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .frame(maxWidth: .infinity)
                }
                .accessibilityLabel("Listen")

                Button { go(to: index + 1, count: list.count) } label: {
                    Label("Next", systemImage: "chevron.right")
                        .frame(maxWidth: .infinity)
                }
                .disabled(index >= list.count - 1)
            }
            .buttonStyle(.bordered)

            Button {
                progress.toggleLearned(card)
            } label: {
                Label(progress.isLearned(card) ? "Learned" : "Mark as learned",
                      systemImage: progress.isLearned(card) ? "checkmark.circle.fill" : "circle")
            }
            .tint(progress.isLearned(card) ? .green : .accentColor)

            Spacer()
        }
        .padding()
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func go(to newIndex: Int, count: Int) {
        guard (0..<count).contains(newIndex) else { return }
        flipped = false
        index = newIndex
    }
}

struct FlipCard: View {
    let entry: Entry
    let flipped: Bool

    var body: some View {
        ZStack {
            front
                .opacity(flipped ? 0 : 1)

            back
                .opacity(flipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }

    private var front: some View {
        face(color: .blue) {
            Text("ENGLISH")
                .font(.caption.bold())
                .foregroundStyle(.blue)
            Text(entry.english)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
        }
    }

    private var back: some View {
        face(color: .green) {
            Text("TRANSLATION")
                .font(.caption.bold())
                .foregroundStyle(.green)
            Text(entry.translation)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(entry.pronunciation)
                .font(.title3.italic())
                .foregroundStyle(.blue)
            if let note = entry.note {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func face<Inner: View>(color: Color, @ViewBuilder content: () -> Inner) -> some View {
        VStack(spacing: 12) {
            content()
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 240)
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

// MARK: - Quiz

struct QuizQuestion: Identifiable {
    let id = UUID()
    let entry: Entry
    let options: [String]

    static func make(from pool: [Entry], count: Int = 8) -> [QuizQuestion] {
        pool.shuffled().prefix(count).map { entry in
            let distractors = pool
                .filter { $0.translation != entry.translation }
                .shuffled()
                .prefix(3)
                .map { $0.translation }
            return QuizQuestion(entry: entry, options: ([entry.translation] + distractors).shuffled())
        }
    }
}

struct QuizView: View {
    let language: Language
    let category: Category?

    @EnvironmentObject var progress: ProgressStore
    @State private var questions: [QuizQuestion]
    @State private var index = 0
    @State private var selected: String?
    @State private var score = 0
    @State private var finished = false

    init(language: Language, category: Category?) {
        self.language = language
        self.category = category
        let all = Content.entries(for: language)
        let pool = category == nil ? all : all.filter { $0.category == category }
        _questions = State(initialValue: QuizQuestion.make(from: pool))
    }

    private var pool: [Entry] {
        let all = Content.entries(for: language)
        return category == nil ? all : all.filter { $0.category == category }
    }

    var body: some View {
        Group {
            if finished {
                resultView
            } else if index < questions.count {
                questionView(questions[index])
            }
        }
        .navigationTitle(category?.rawValue ?? "Mixed Test")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Question

    private func questionView(_ q: QuizQuestion) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                ProgressView(value: Double(index), total: Double(questions.count))
                    .tint(.blue)

                Text("Question \(index + 1) of \(questions.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Translate to \(language.rawValue):")
                    .foregroundStyle(.secondary)

                Text(q.entry.english)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 6)

                ForEach(q.options, id: \.self) { option in
                    Button {
                        choose(option, for: q)
                    } label: {
                        HStack {
                            Text(option)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if let icon = icon(for: option, in: q) {
                                Image(systemName: icon)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(color(for: option, in: q).opacity(0.15),
                                    in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(color(for: option, in: q), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }

                if selected != nil {
                    VStack(spacing: 10) {
                        HStack {
                            Text(q.entry.pronunciation)
                                .italic()
                                .foregroundStyle(.blue)
                            Button {
                                Speaker.shared.speak(q.entry.translation, language: language)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                            }
                            .accessibilityLabel("Listen")
                        }

                        Button {
                            next()
                        } label: {
                            Text(index + 1 == questions.count ? "See Results" : "Next Question")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 6)
                }
            }
            .padding()
        }
    }

    private func color(for option: String, in q: QuizQuestion) -> Color {
        guard let chosen = selected else { return .blue }
        if option == q.entry.translation { return .green }
        if option == chosen { return .red }
        return .gray
    }

    private func icon(for option: String, in q: QuizQuestion) -> String? {
        guard let chosen = selected else { return nil }
        if option == q.entry.translation { return "checkmark.circle.fill" }
        if option == chosen { return "xmark.circle.fill" }
        return nil
    }

    // MARK: Result

    private var resultView: some View {
        let total = max(questions.count, 1)
        let percent = Int((Double(score) / Double(total) * 100).rounded())

        return VStack(spacing: 18) {
            Spacer()
            Text(percent >= 80 ? "🏆" : percent >= 50 ? "👍" : "📚")
                .font(.system(size: 70))
            Text("You scored \(score) / \(questions.count)")
                .font(.title.bold())
            Text("\(percent)%")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(percent >= 80 ? .green : percent >= 50 ? .orange : .red)
            Text(percent >= 80 ? "Excellent work!" :
                 percent >= 50 ? "Good job, keep practicing!" : "Review the flashcards and try again.")
                .foregroundStyle(.secondary)
            Spacer()

            Button {
                restart()
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: Actions

    private func choose(_ option: String, for q: QuizQuestion) {
        guard selected == nil else { return }
        selected = option
        if option == q.entry.translation {
            score += 1
            progress.markLearned(q.entry)
        }
    }

    private func next() {
        if index + 1 < questions.count {
            index += 1
            selected = nil
        } else {
            let total = max(questions.count, 1)
            let percent = Int((Double(score) / Double(total) * 100).rounded())
            progress.recordScore(percent, key: scoreKey(language: language, category: category))
            finished = true
        }
    }

    private func restart() {
        questions = QuizQuestion.make(from: pool)
        index = 0
        selected = nil
        score = 0
        finished = false
    }
}

#Preview {
    HomeView()
        .environmentObject(ProgressStore())
}
