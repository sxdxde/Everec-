import UIKit

enum Theme {
    static var currentMode: UIUserInterfaceStyle {
        get {
            UIUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: "themeMode")) ?? .unspecified
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "themeMode")
            applyTheme()
        }
    }

    static func applyTheme() {
        for scene in UIApplication.shared.connectedScenes {
            guard let ws = scene as? UIWindowScene else { continue }
            for window in ws.windows {
                window.overrideUserInterfaceStyle = currentMode
            }
        }
    }

    static let background = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.026, green: 0.096, blue: 0.190, alpha: 1)
            : UIColor(red: 0.98, green: 0.97, blue: 0.94, alpha: 1)
    }

    static let primaryText = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.967, green: 0.993, blue: 0.789, alpha: 1)
            : UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1)
    }

    static let accent = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.911, green: 0.937, blue: 0.743, alpha: 1)
            : UIColor(red: 0.30, green: 0.42, blue: 0.25, alpha: 1)
    }

    static let tint = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.700, green: 0.720, blue: 0.571, alpha: 1)
            : UIColor(red: 0.45, green: 0.48, blue: 0.40, alpha: 1)
    }

    static let cellBackground = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.050, green: 0.140, blue: 0.270, alpha: 1)
            : UIColor(red: 0.94, green: 0.93, blue: 0.90, alpha: 1)
    }
}
