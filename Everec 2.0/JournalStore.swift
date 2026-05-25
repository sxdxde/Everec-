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
