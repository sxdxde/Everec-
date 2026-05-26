import Foundation

struct JournalEntry: Codable {
    let id: UUID
    let mood: String
    let date: Date
    let audioFileName: String
    var title: String?
    var transcription: String?
    var tags: [String]
    var formattedTranscription: Data?

    var moodType: Mood? {
        Mood(rawValue: mood)
    }

    var displayMood: String {
        moodType?.emoji ?? mood
    }

    init(mood: String, date: Date, audioFileName: String, title: String? = nil, transcription: String? = nil, tags: [String] = [], formattedTranscription: Data? = nil) {
        self.id = UUID()
        self.mood = mood
        self.date = date
        self.audioFileName = audioFileName
        self.title = title
        self.transcription = transcription
        self.tags = tags
        self.formattedTranscription = formattedTranscription
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        mood = try c.decode(String.self, forKey: .mood)
        date = try c.decode(Date.self, forKey: .date)
        audioFileName = try c.decode(String.self, forKey: .audioFileName)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        transcription = try c.decodeIfPresent(String.self, forKey: .transcription)
        tags = (try? c.decodeIfPresent([String].self, forKey: .tags)) ?? []
        formattedTranscription = try? c.decodeIfPresent(Data.self, forKey: .formattedTranscription)
    }
}
