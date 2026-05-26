import Foundation

class JournalStore {
    static let shared = JournalStore()

    private let fileManager = FileManager.default
    private var entries: [JournalEntry] = []

    private var storeURL: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("journal_entries.json")
    }

    var audioDirectory: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("Recordings")
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private init() {
        load()
    }

    func allEntries() -> [JournalEntry] {
        entries.sorted { $0.date > $1.date }
    }

    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
        save()
    }

    func updateEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            save()
        }
    }

    func updateTranscription(for entryId: UUID, transcription: String) {
        if let index = entries.firstIndex(where: { $0.id == entryId }) {
            entries[index].transcription = transcription
            save()
        }
    }

    func deleteEntry(at sortedIndex: Int) {
        let sorted = allEntries()
        guard sortedIndex < sorted.count else { return }
        let entry = sorted[sortedIndex]
        let audioURL = audioDirectory.appendingPathComponent(entry.audioFileName)
        try? fileManager.removeItem(at: audioURL)
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func deleteEntry(id: UUID) {
        guard let entry = entries.first(where: { $0.id == id }) else { return }
        let audioURL = audioDirectory.appendingPathComponent(entry.audioFileName)
        try? fileManager.removeItem(at: audioURL)
        entries.removeAll { $0.id == id }
        save()
    }

    func search(text: String?, mood: Mood?) -> [JournalEntry] {
        var results = allEntries()
        if let mood {
            results = results.filter { $0.mood == mood.rawValue }
        }
        if let text, !text.isEmpty {
            let lower = text.lowercased()
            results = results.filter {
                ($0.title?.lowercased().contains(lower) ?? false) ||
                ($0.transcription?.lowercased().contains(lower) ?? false) ||
                $0.tags.contains { $0.lowercased().contains(lower) }
            }
        }
        return results
    }

    func moodCounts(days: Int) -> [Mood: Int] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        var counts: [Mood: Int] = [:]
        for m in Mood.allCases { counts[m] = 0 }
        for entry in entries where entry.date >= cutoff {
            if let mood = entry.moodType {
                counts[mood, default: 0] += 1
            }
        }
        return counts
    }

    func currentStreak() -> Int {
        let cal = Calendar.current
        let sorted = entries.sorted { $0.date > $1.date }
        guard let latest = sorted.first else { return 0 }

        let today = cal.startOfDay(for: Date())
        let latestDay = cal.startOfDay(for: latest.date)
        guard cal.dateComponents([.day], from: latestDay, to: today).day! <= 1 else { return 0 }

        var streak = 1
        var days = Set<Date>()
        for e in sorted { days.insert(cal.startOfDay(for: e.date)) }
        let sortedDays = days.sorted(by: >)

        for i in 1..<sortedDays.count {
            let diff = cal.dateComponents([.day], from: sortedDays[i], to: sortedDays[i - 1]).day!
            if diff == 1 { streak += 1 } else { break }
        }
        return streak
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: storeURL)
    }

    private func load() {
        guard let data = try? Data(contentsOf: storeURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        entries = (try? decoder.decode([JournalEntry].self, from: data)) ?? []
    }
}
