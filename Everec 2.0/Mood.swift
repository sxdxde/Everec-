import UIKit

enum Mood: String, Codable, CaseIterable {
    case happy, calm, anxious, sad, angry, neutral

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .calm: return "😌"
        case .anxious: return "😰"
        case .sad: return "😢"
        case .angry: return "😠"
        case .neutral: return "😐"
        }
    }

    var label: String {
        switch self {
        case .happy: return "Happy"
        case .calm: return "Calm"
        case .anxious: return "Anxious"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .neutral: return "Neutral"
        }
    }

    var color: UIColor {
        switch self {
        case .happy: return .systemGreen
        case .calm: return .systemBlue
        case .anxious: return .systemOrange
        case .sad: return .systemIndigo
        case .angry: return .systemRed
        case .neutral: return .systemGray
        }
    }
}
