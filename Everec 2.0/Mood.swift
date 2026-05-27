import UIKit

enum Mood: String, Codable, CaseIterable {
    case happy, calm, anxious, sad, angry, neutral

    var iconName: String {
        switch self {
        case .happy: return "sun.max.fill"
        case .calm: return "leaf.fill"
        case .anxious: return "bolt.heart.fill"
        case .sad: return "cloud.rain.fill"
        case .angry: return "flame.fill"
        case .neutral: return "circle.lefthalf.filled"
        }
    }

    func icon(pointSize: CGFloat = 24, weight: UIImage.SymbolWeight = .medium) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        return UIImage(systemName: iconName, withConfiguration: config)
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

    static let navy = UIColor(red: 0.06, green: 0.13, blue: 0.37, alpha: 1.0)
    static let gold = UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)

    var color: UIColor {
        Mood.gold
    }
}
