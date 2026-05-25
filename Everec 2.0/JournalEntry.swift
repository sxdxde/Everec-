import Foundation

struct JournalEntry: Codable {
    let id: UUID
    let mood: String
    let date: Date
    let audioFileName: String
    var title: String?
    var transcription: String?

    init(mood: String, date: Date, audioFileName: String, title: String? = nil, transcription: String? = nil) {
        self.id = UUID()
        self.mood = mood
        self.date = date
        self.audioFileName = audioFileName
        self.title = title
        self.transcription = transcription
    }
}
