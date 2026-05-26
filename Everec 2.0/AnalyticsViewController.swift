import UIKit

class AnalyticsViewController: UIViewController {

    private let store = JournalStore.shared
    private let segmentedControl = UISegmentedControl(items: ["7 Days", "30 Days"])
    private let chartStack = UIStackView()
    private let streakLabel = UILabel()
    private let totalLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        navigationItem.title = "Insights"
        setupUI()
        updateChart()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupUI() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        segmentedControl.selectedSegmentTintColor = Theme.accent
        segmentedControl.setTitleTextAttributes([.foregroundColor: Theme.background], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: Theme.accent], for: .normal)

        let statsStack = UIStackView()
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 16

        let streakCard = makeStatCard(title: "Current Streak", valueLabel: streakLabel)
        let totalCard = makeStatCard(title: "Total Entries", valueLabel: totalLabel)
        statsStack.addArrangedSubview(streakCard)
        statsStack.addArrangedSubview(totalCard)

        let chartLabel = UILabel()
        chartLabel.text = "Mood Distribution"
        chartLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        chartLabel.textColor = Theme.primaryText

        chartStack.axis = .horizontal
        chartStack.alignment = .bottom
        chartStack.distribution = .fillEqually
        chartStack.spacing = 8

        let chartContainer = UIView()
        chartContainer.backgroundColor = Theme.cellBackground
        chartContainer.layer.cornerRadius = 12
        chartStack.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.addSubview(chartStack)

        NSLayoutConstraint.activate([
            chartStack.topAnchor.constraint(equalTo: chartContainer.topAnchor, constant: 16),
            chartStack.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor, constant: 12),
            chartStack.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor, constant: -12),
            chartStack.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor, constant: -16),
            chartStack.heightAnchor.constraint(equalToConstant: 180),
        ])

        [segmentedControl, statsStack, chartLabel, chartContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statsStack.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            statsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statsStack.heightAnchor.constraint(equalToConstant: 80),

            chartLabel.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 24),
            chartLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            chartContainer.topAnchor.constraint(equalTo: chartLabel.bottomAnchor, constant: 12),
            chartContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chartContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    private func makeStatCard(title: String, valueLabel: UILabel) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.cellBackground
        card.layer.cornerRadius = 12

        let t = UILabel()
        t.text = title
        t.font = .systemFont(ofSize: 12, weight: .medium)
        t.textColor = Theme.tint

        valueLabel.font = .monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        valueLabel.textColor = Theme.accent
        valueLabel.text = "0"

        let s = UIStackView(arrangedSubviews: [t, valueLabel])
        s.axis = .vertical
        s.spacing = 4
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(s)

        NSLayoutConstraint.activate([
            s.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            s.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])
        return card
    }

    @objc private func periodChanged() {
        updateChart()
    }

    private func updateChart() {
        let days = segmentedControl.selectedSegmentIndex == 0 ? 7 : 30
        let counts = store.moodCounts(days: days)
        let maxCount = counts.values.max() ?? 1

        streakLabel.text = "\(store.currentStreak())"
        totalLabel.text = "\(store.allEntries().count)"

        chartStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for mood in Mood.allCases {
            let count = counts[mood] ?? 0
            let column = UIView()

            let bar = UIView()
            bar.backgroundColor = mood.color
            bar.layer.cornerRadius = 4

            let emoji = UILabel()
            emoji.text = mood.emoji
            emoji.font = .systemFont(ofSize: 20)
            emoji.textAlignment = .center

            let countLabel = UILabel()
            countLabel.text = "\(count)"
            countLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
            countLabel.textColor = Theme.tint
            countLabel.textAlignment = .center

            [countLabel, bar, emoji].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                column.addSubview($0)
            }

            let fraction = maxCount > 0 ? CGFloat(count) / CGFloat(maxCount) : 0
            let minHeight: CGFloat = 4

            NSLayoutConstraint.activate([
                emoji.bottomAnchor.constraint(equalTo: column.bottomAnchor),
                emoji.centerXAnchor.constraint(equalTo: column.centerXAnchor),

                bar.bottomAnchor.constraint(equalTo: emoji.topAnchor, constant: -4),
                bar.centerXAnchor.constraint(equalTo: column.centerXAnchor),
                bar.widthAnchor.constraint(equalToConstant: 24),
                bar.heightAnchor.constraint(equalTo: column.heightAnchor, multiplier: max(0.03, fraction * 0.6), constant: minHeight),

                countLabel.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -4),
                countLabel.centerXAnchor.constraint(equalTo: column.centerXAnchor),
            ])

            chartStack.addArrangedSubview(column)
        }
    }
}
