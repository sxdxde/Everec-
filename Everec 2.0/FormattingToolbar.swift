import UIKit

class FormattingToolbar: UIView {
    weak var textView: UITextView?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = Theme.cellBackground
        autoresizingMask = .flexibleWidth

        let sep = UIView()
        sep.backgroundColor = Theme.tint.withAlphaComponent(0.2)

        let bold = makeButton(title: "B", font: .boldSystemFont(ofSize: 18), action: #selector(boldTapped))
        let italic = makeButton(title: "I", font: .italicSystemFont(ofSize: 18), action: #selector(italicTapped))
        let highlight = makeButton(image: UIImage(systemName: "highlighter"), action: #selector(highlightTapped))
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let done = makeButton(title: "Done", font: .systemFont(ofSize: 16, weight: .medium), action: #selector(doneTapped))

        let stack = UIStackView(arrangedSubviews: [bold, italic, highlight, spacer, done])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center

        [sep, stack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; addSubview($0) }
        NSLayoutConstraint.activate([
            sep.topAnchor.constraint(equalTo: topAnchor), sep.leadingAnchor.constraint(equalTo: leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: trailingAnchor), sep.heightAnchor.constraint(equalToConstant: 0.5),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 4), stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16), stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }

    private func makeButton(title: String? = nil, font: UIFont? = nil, image: UIImage? = nil, action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        if let title { b.setTitle(title, for: .normal) }
        if let font { b.titleLabel?.font = font }
        if let image { b.setImage(image, for: .normal) }
        b.tintColor = Theme.accent
        b.setTitleColor(Theme.accent, for: .normal)
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    @objc private func boldTapped() { toggleTrait(.traitBold) }
    @objc private func italicTapped() { toggleTrait(.traitItalic) }
    @objc private func doneTapped() { textView?.resignFirstResponder() }

    @objc private func highlightTapped() {
        guard let textView, let range = textView.selectedTextRange, !range.isEmpty else { return }
        let ns = nsRange(from: range)
        let m = NSMutableAttributedString(attributedString: textView.attributedText)
        var has = false
        m.enumerateAttribute(.backgroundColor, in: ns) { v, _, _ in if v != nil { has = true } }
        if has { m.removeAttribute(.backgroundColor, range: ns) }
        else { m.addAttribute(.backgroundColor, value: UIColor.systemYellow.withAlphaComponent(0.3), range: ns) }
        textView.attributedText = m
    }

    private func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        guard let textView, let range = textView.selectedTextRange, !range.isEmpty else { return }
        let ns = nsRange(from: range)
        let m = NSMutableAttributedString(attributedString: textView.attributedText)
        m.enumerateAttribute(.font, in: ns, options: []) { value, r, _ in
            guard let font = value as? UIFont else { return }
            var traits = font.fontDescriptor.symbolicTraits
            if traits.contains(trait) { traits.remove(trait) } else { traits.insert(trait) }
            if let d = font.fontDescriptor.withSymbolicTraits(traits) {
                m.addAttribute(.font, value: UIFont(descriptor: d, size: font.pointSize), range: r)
            }
        }
        textView.attributedText = m
    }

    private func nsRange(from range: UITextRange) -> NSRange {
        guard let tv = textView else { return NSRange(location: 0, length: 0) }
        let s = tv.offset(from: tv.beginningOfDocument, to: range.start)
        let l = tv.offset(from: range.start, to: range.end)
        return NSRange(location: s, length: l)
    }
}
