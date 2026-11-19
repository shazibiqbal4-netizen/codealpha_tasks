import SwiftUI

// MARK: - App entry point

@main
struct FitnessTrackerApp: App {
    @StateObject private var store = FitnessStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

// MARK: - Models

enum ActivityType: String, CaseIterable, Codable, Identifiable {
    case walking = "Walking"
    case running = "Running"
    case cycling = "Cycling"
    case workout = "Workout"
    case yoga = "Yoga"
    case swimming = "Swimming"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .workout: return "dumbbell.fill"
        case .yoga: return "figure.yoga"
        case .swimming: return "figure.pool.swim"
        case .other: return "star.fill"
        }
    }
}

struct FitnessEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var date: Date
    var type: ActivityType
    var steps: Int
    var minutes: Int
    var calories: Int
}

struct DayTotal: Identifiable {
    let date: Date
    let steps: Int
    let minutes: Int
    let calories: Int
    var id: Date { date }
}

enum Metric: String, CaseIterable, Identifiable {
    case steps = "Steps"
    case calories = "Calories"
    case minutes = "Minutes"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .steps: return .blue
        case .calories: return .orange
        case .minutes: return .green
        }
    }

    var unit: String {
        switch self {
        case .steps: return "steps"
        case .calories: return "kcal"
        case .minutes: return "min"
        }
    }

    func value(for day: DayTotal) -> Int {
        switch self {
        case .steps: return day.steps
        case .calories: return day.calories
        case .minutes: return day.minutes
        }
    }
}

// MARK: - Store (local storage using UserDefaults)

final class FitnessStore: ObservableObject {
    @Published private(set) var entries: [FitnessEntry] = []

    private let storageKey = "fitness.entries.v1"

    init() { load() }

    var sortedEntries: [FitnessEntry] {
        entries.sorted { $0.date > $1.date }
    }

    func add(_ entry: FitnessEntry) {
        entries.append(entry)
        save()
    }

    func delete(_ entry: FitnessEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    /// Totals for a single calendar day.
    func total(on day: Date) -> DayTotal {
        let cal = Calendar.current
        let items = entries.filter { cal.isDate($0.date, inSameDayAs: day) }
        return DayTotal(
            date: cal.startOfDay(for: day),
            steps: items.reduce(0) { $0 + $1.steps },
            minutes: items.reduce(0) { $0 + $1.minutes },
            calories: items.reduce(0) { $0 + $1.calories }
        )
    }

    /// Totals for the last 7 days, oldest first (today is last).
    func lastSevenDays() -> [DayTotal] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { offset in
            cal.date(byAdding: .day, value: -offset, to: today).map { total(on: $0) }
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([FitnessEntry].self, from: data) else { return }
        entries = saved
    }
}

// MARK: - Root tabs

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "list.bullet") }
        }
    }
}

// MARK: - Dashboard

struct DashboardView: View {
    @EnvironmentObject var store: FitnessStore

    @AppStorage("goalSteps") private var goalSteps = 10000
    @AppStorage("goalCalories") private var goalCalories = 500
    @AppStorage("goalMinutes") private var goalMinutes = 30

    @State private var metric: Metric = .steps
    @State private var showAdd = false
    @State private var showGoals = false

    var body: some View {
        let today = store.total(on: Date())
        let week = store.lastSevenDays()

        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todayCard(today)
                    weekCard(week)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showGoals = true } label: { Image(systemName: "target") }
                        .accessibilityLabel("Edit goals")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Log activity")
                }
            }
            .sheet(isPresented: $showAdd) { AddEntryView() }
            .sheet(isPresented: $showGoals) { GoalsView() }
        }
    }

    private func todayCard(_ today: DayTotal) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today")
                .font(.headline)

            ProgressRow(title: "Steps", icon: "figure.walk", value: today.steps,
                        goal: goalSteps, color: .blue, unit: "steps")
            ProgressRow(title: "Calories", icon: "flame.fill", value: today.calories,
                        goal: goalCalories, color: .orange, unit: "kcal")
            ProgressRow(title: "Active time", icon: "timer", value: today.minutes,
                        goal: goalMinutes, color: .green, unit: "min")
        }
        .cardStyle()
    }

    private func weekCard(_ week: [DayTotal]) -> some View {
        let total = week.reduce(0) { $0 + metric.value(for: $1) }

        return VStack(alignment: .leading, spacing: 14) {
            Text("Last 7 Days")
                .font(.headline)

            Picker("Metric", selection: $metric) {
                ForEach(Metric.allCases) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)

            WeeklyChart(days: week, metric: metric)

            HStack {
                stat("Weekly total", total)
                Spacer()
                stat("Daily average", total / 7)
            }
        }
        .cardStyle()
    }

    private func stat(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value) \(metric.unit)")
                .font(.headline)
        }
    }
}

struct ProgressRow: View {
    let title: String
    let icon: String
    let value: Int
    let goal: Int
    let color: Color
    let unit: String

    var body: some View {
        let safeGoal = Double(max(goal, 1))

        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline.bold())
                    .foregroundStyle(color)
                Spacer()
                Text("\(value) / \(goal) \(unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: min(Double(value), safeGoal), total: safeGoal)
                .tint(color)
        }
    }
}

struct WeeklyChart: View {
    let days: [DayTotal]
    let metric: Metric

    var body: some View {
        let maxValue = max(days.map { metric.value(for: $0) }.max() ?? 0, 1)

        HStack(alignment: .bottom, spacing: 8) {
            ForEach(days) { day in
                let value = metric.value(for: day)

                VStack(spacing: 6) {
                    Text("\(value)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(metric.color.gradient)
                        .frame(height: max(4, CGFloat(value) / CGFloat(maxValue) * 140))

                    Text(day.date, format: .dateTime.weekday(.abbreviated))
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 200)
        .animation(.easeInOut, value: metric)
    }
}

// MARK: - History

struct HistoryView: View {
    @EnvironmentObject var store: FitnessStore
    @State private var showAdd = false

    var body: some View {
        let items = store.sortedEntries

        NavigationStack {
            Group {
                if items.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "figure.run.circle")
                            .font(.system(size: 56))
                            .foregroundStyle(.secondary)
                        Text("No activities yet")
                            .font(.title3.bold())
                        Text("Tap + to log your first workout.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(items) { entry in
                            row(entry)
                        }
                        .onDelete { offsets in
                            offsets.map { items[$0] }.forEach { store.delete($0) }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Log activity")
                }
            }
            .sheet(isPresented: $showAdd) { AddEntryView() }
        }
    }

    private func row(_ entry: FitnessEntry) -> some View {
        HStack(spacing: 14) {
            Image(systemName: entry.type.icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(Color.blue.gradient, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.type.rawValue)
                    .font(.headline)
                Text(details(entry))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private func details(_ entry: FitnessEntry) -> String {
        var parts: [String] = []
        if entry.steps > 0 { parts.append("\(entry.steps) steps") }
        if entry.minutes > 0 { parts.append("\(entry.minutes) min") }
        if entry.calories > 0 { parts.append("\(entry.calories) kcal") }
        return parts.joined(separator: " · ")
    }
}

// MARK: - Add activity

struct AddEntryView: View {
    @EnvironmentObject var store: FitnessStore
    @Environment(\.dismiss) private var dismiss

    @State private var type: ActivityType = .walking
    @State private var date = Date()
    @State private var steps = ""
    @State private var minutes = ""
    @State private var calories = ""

    private var canSave: Bool {
        (Int(steps) ?? 0) > 0 || (Int(minutes) ?? 0) > 0 || (Int(calories) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity") {
                    Picker("Type", selection: $type) {
                        ForEach(ActivityType.allCases) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                }

                Section("Details") {
                    field("Steps", text: $steps, unit: "steps")
                    field("Duration", text: $minutes, unit: "min")
                    field("Calories burned", text: $calories, unit: "kcal")
                }
            }
            .navigationTitle("Log Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(FitnessEntry(
                            date: date,
                            type: type,
                            steps: Int(steps) ?? 0,
                            minutes: Int(minutes) ?? 0,
                            calories: Int(calories) ?? 0
                        ))
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private func field(_ label: String, text: Binding<String>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)
            Text(unit)
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .leading)
        }
    }
}

// MARK: - Goals

struct GoalsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("goalSteps") private var goalSteps = 10000
    @AppStorage("goalCalories") private var goalCalories = 500
    @AppStorage("goalMinutes") private var goalMinutes = 30

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily goals") {
                    Stepper("Steps: \(goalSteps)", value: $goalSteps, in: 1000...50000, step: 500)
                    Stepper("Calories: \(goalCalories) kcal", value: $goalCalories, in: 50...3000, step: 50)
                    Stepper("Active time: \(goalMinutes) min", value: $goalMinutes, in: 5...300, step: 5)
                }
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Helpers

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ContentView()
        .environmentObject(FitnessStore())
}
