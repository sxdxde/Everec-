import UIKit

class AnalyticsViewController: UIViewController {

    private let store = JournalStore.shared
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        setupNavigationBar()
        setupUI()
        populateStats()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupNavigationBar() {
        navigationItem.title = "Analytics"

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.background
        appearance.titleTextAttributes = [.foregroundColor: Theme.primaryText]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Theme.accent
    }

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    private func populateStats() {
        let entries = store.allEntries()
        let streak = store.currentStreak()
        let counts = store.moodCounts(days: 30)
        let favoriteMood = counts.max { $0.value < $1.value }?.key

        stackView.addArrangedSubview(makeSummaryCard(title: "Total Entries", value: "\(entries.count)", subtitle: "All journal recordings"))
        stackView.addArrangedSubview(makeSummaryCard(title: "Current Streak", value: "\(streak)", subtitle: streak == 1 ? "day" : "days"))

        if let favoriteMood, (counts[favoriteMood] ?? 0) > 0 {
            stackView.addArrangedSubview(makeSummaryCard(title: "Most Logged Mood", value: favoriteMood.emoji, subtitle: favoriteMood.label))
        }

        let header = UILabel()
        header.text = "Last 30 Days"
        header.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textColor = Theme.primaryText
        stackView.addArrangedSubview(header)

        for mood in Mood.allCases {
            stackView.addArrangedSubview(makeMoodRow(mood: mood, count: counts[mood] ?? 0))
        }
    }

    private func makeSummaryCard(title: String, value: String, subtitle: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = Theme.tint

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = Theme.primaryText

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = Theme.accent

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4

        let container = UIView()
        container.backgroundColor = Theme.cellBackground
        container.layer.cornerRadius = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
        ])

        return container
    }

    private func makeMoodRow(mood: Mood, count: Int) -> UIView {
        let emojiLabel = UILabel()
        emojiLabel.text = mood.emoji
        emojiLabel.font = .systemFont(ofSize: 28)
        emojiLabel.setContentHuggingPriority(.required, for: .horizontal)

        let nameLabel = UILabel()
        nameLabel.text = mood.label
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = Theme.primaryText

        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        countLabel.textColor = Theme.accent
        countLabel.textAlignment = .right
        countLabel.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [emojiLabel, nameLabel, countLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center

        let container = UIView()
        container.backgroundColor = Theme.cellBackground
        container.layer.cornerRadius = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
        ])

        return container
    }
}
