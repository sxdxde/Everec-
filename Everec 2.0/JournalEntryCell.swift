import UIKit

class JournalEntryCell: UITableViewCell {

    private let moodLabel = UILabel()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let transcriptionLabel = UILabel()
    private let tagsStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = Theme.background
        accessoryType = .disclosureIndicator

        let selectedBg = UIView()
        selectedBg.backgroundColor = Theme.cellBackground
        selectedBackgroundView = selectedBg

        moodLabel.font = .systemFont(ofSize: 28)
        moodLabel.setContentHuggingPriority(.required, for: .horizontal)
        moodLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = Theme.primaryText

        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = Theme.accent

        transcriptionLabel.font = .systemFont(ofSize: 13)
        transcriptionLabel.textColor = Theme.tint
        transcriptionLabel.numberOfLines = 1

        tagsStack.axis = .horizontal
        tagsStack.spacing = 4
        tagsStack.alignment = .center

        let textStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel, transcriptionLabel, tagsStack])
        textStack.axis = .vertical
        textStack.spacing = 3

        let mainStack = UIStackView(arrangedSubviews: [moodLabel, textStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    func configure(with entry: JournalEntry) {
        moodLabel.text = entry.displayMood

        if let title = entry.title, !title.isEmpty {
            titleLabel.text = title
            titleLabel.textColor = Theme.primaryText
        } else {
            titleLabel.text = "Untitled Entry"
            titleLabel.textColor = Theme.tint.withAlphaComponent(0.5)
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: entry.date)

        if let transcription = entry.transcription, !transcription.isEmpty {
            transcriptionLabel.text = transcription
            transcriptionLabel.isHidden = false
        } else {
            transcriptionLabel.isHidden = true
        }

        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if entry.tags.isEmpty {
            tagsStack.isHidden = true
        } else {
            tagsStack.isHidden = false
            for tag in entry.tags.prefix(3) {
                let pill = UILabel()
                pill.text = "  \(tag)  "
                pill.font = .systemFont(ofSize: 10, weight: .medium)
                pill.textColor = Theme.accent
                pill.backgroundColor = Theme.accent.withAlphaComponent(0.12)
                pill.layer.cornerRadius = 8
                pill.clipsToBounds = true
                tagsStack.addArrangedSubview(pill)
            }
            if entry.tags.count > 3 {
                let more = UILabel()
                more.text = "+\(entry.tags.count - 3)"
                more.font = .systemFont(ofSize: 10, weight: .medium)
                more.textColor = Theme.tint
                tagsStack.addArrangedSubview(more)
            }
        }
    }
}
