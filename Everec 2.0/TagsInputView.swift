import UIKit

protocol TagsInputViewDelegate: AnyObject {
    func tagsDidChange(_ tags: [String])
}

class TagsInputView: UIView {
    weak var delegate: TagsInputViewDelegate?
    private(set) var tags: [String] = []
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        scrollView.showsHorizontalScrollIndicator = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 34),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
    }

    func setTags(_ tags: [String]) {
        self.tags = tags
        rebuild()
    }

    private func rebuild() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, tag) in tags.enumerated() {
            stackView.addArrangedSubview(makeChip(tag, index: i))
        }
        let add = UIButton(type: .system)
        add.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18)), for: .normal)
        add.tintColor = Theme.accent
        add.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        stackView.addArrangedSubview(add)
    }

    private func makeChip(_ tag: String, index: Int) -> UIView {
        let pill = UIView()
        pill.backgroundColor = Theme.accent.withAlphaComponent(0.15)
        pill.layer.cornerRadius = 14

        let label = UILabel()
        label.text = tag
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = Theme.accent

        let x = UIButton(type: .system)
        x.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12)), for: .normal)
        x.tintColor = Theme.tint
        x.tag = index
        x.addTarget(self, action: #selector(removeTapped(_:)), for: .touchUpInside)

        let s = UIStackView(arrangedSubviews: [label, x])
        s.axis = .horizontal
        s.spacing = 4
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(s)
        NSLayoutConstraint.activate([
            s.topAnchor.constraint(equalTo: pill.topAnchor, constant: 4),
            s.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 10),
            s.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -6),
            s.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -4),
        ])
        return pill
    }

    @objc private func addTapped() {
        guard let vc = sequence(first: self as UIResponder, next: \.next).compactMap({ $0 as? UIViewController }).first else { return }
        let alert = UIAlertController(title: "Add Tag", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "e.g. gratitude, work, health"; $0.autocapitalizationType = .none }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty, let self, !self.tags.contains(text) else { return }
            self.tags.append(text)
            self.rebuild()
            self.delegate?.tagsDidChange(self.tags)
        })
        vc.present(alert, animated: true)
    }

    @objc private func removeTapped(_ sender: UIButton) {
        guard sender.tag < tags.count else { return }
        tags.remove(at: sender.tag)
        rebuild()
        delegate?.tagsDidChange(tags)
    }
}
