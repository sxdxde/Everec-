import UIKit

class WaveformView: UIView {
    var levels: [CGFloat] = []
    var barColor: UIColor = Theme.accent { didSet { setNeedsDisplay() } }

    func addLevel(_ level: CGFloat) {
        levels.append(min(1, max(0, level)))
        if levels.count > 80 { levels.removeFirst() }
        setNeedsDisplay()
    }

    func reset() {
        levels.removeAll()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !levels.isEmpty else { return }
        let barWidth: CGFloat = 3
        let gap: CGFloat = 2
        let step = barWidth + gap
        let visibleBars = min(levels.count, Int(rect.width / step))
        let displayLevels = Array(levels.suffix(visibleBars))
        let startX = rect.width - CGFloat(displayLevels.count) * step

        barColor.setFill()
        for (i, level) in displayLevels.enumerated() {
            let x = startX + CGFloat(i) * step
            let h = max(2, level * rect.height * 0.9)
            let y = (rect.height - h) / 2
            UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: h), cornerRadius: barWidth / 2).fill()
        }
    }
}
