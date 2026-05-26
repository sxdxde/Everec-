import UIKit

class MoodSelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.hidesBackButton = true
        setupNavigationBar()
        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.background
        appearance.titleTextAttributes = [.foregroundColor: Theme.primaryText]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Theme.accent
        navigationItem.title = "Everec"

        let analytics = UIBarButtonItem(
            image: UIImage(systemName: "chart.bar.fill"),
            style: .plain, target: self, action: #selector(analyticsTapped)
        )
        let settings = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain, target: self, action: #selector(settingsTapped)
        )
        navigationItem.rightBarButtonItems = [settings, analytics]
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "How are you feeling?"
        titleLabel.font = .systemFont(ofSize: 28, weight: .medium)
        titleLabel.textColor = Theme.primaryText
        titleLabel.textAlignment = .center

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 16
        grid.distribution = .fillEqually

        let moods = Mood.allCases
        for row in 0..<2 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            rowStack.distribution = .fillEqually
            for col in 0..<3 {
                let mood = moods[row * 3 + col]
                let button = createMoodButton(mood: mood)
                rowStack.addArrangedSubview(button)
            }
            grid.addArrangedSubview(rowStack)
        }

        [titleLabel, grid].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            grid.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            grid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            grid.heightAnchor.constraint(equalToConstant: 260),
        ])
    }

    private func createMoodButton(mood: Mood) -> UIButton {
        let button = UIButton(type: .system)

        let emoji = UILabel()
        emoji.text = mood.emoji
        emoji.font = .systemFont(ofSize: 36)

        let label = UILabel()
        label.text = mood.label
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = Theme.accent

        let stack = UIStackView(arrangedSubviews: [emoji, label])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        ])

        button.backgroundColor = Theme.cellBackground
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.5
        button.layer.borderColor = mood.color.withAlphaComponent(0.3).cgColor
        button.tag = Mood.allCases.firstIndex(of: mood) ?? 0
        button.addTarget(self, action: #selector(moodTapped(_:)), for: .touchUpInside)

        return button
    }

    @objc private func moodTapped(_ sender: UIButton) {
        let mood = Mood.allCases[sender.tag]
        let recordingVC = RecordingViewController()
        recordingVC.mood = mood.rawValue
        navigationController?.pushViewController(recordingVC, animated: true)
    }

    @objc private func analyticsTapped() {
        let vc = AnalyticsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func settingsTapped() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
class AnalyticsViewController: UIViewController {

    private let store = JournalStore.shared
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        navigationItem.title = "Analytics"
        setupNavigationBar()
        setupUI()
        populateStats()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupNavigationBar() {
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
        stackView.axis = .vertical
        stackView.spacing = 16

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

        stackView.addArrangedSubview(makeCard(title: "Total Entries", value: "\(entries.count)", subtitle: "All journal recordings"))
        stackView.addArrangedSubview(makeCard(title: "Current Streak", value: "\(streak)", subtitle: streak == 1 ? "day" : "days"))

        let header = UILabel()
        header.text = "Last 30 Days"
        header.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textColor = Theme.primaryText
        stackView.addArrangedSubview(header)

        for mood in Mood.allCases {
            stackView.addArrangedSubview(makeMoodRow(mood: mood, count: counts[mood] ?? 0))
        }
    }

    private func makeCard(title: String, value: String, subtitle: String) -> UIView {
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

        let nameLabel = UILabel()
        nameLabel.text = mood.label
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = Theme.primaryText

        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        countLabel.textColor = Theme.accent
        countLabel.textAlignment = .right

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

class SettingsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let themeOptions: [(title: String, style: UIUserInterfaceStyle)] = [
        ("System", .unspecified),
        ("Light", .light),
        ("Dark", .dark),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        navigationItem.title = "Settings"
        setupNavigationBar()
        setupTableView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.background
        appearance.titleTextAttributes = [.foregroundColor: Theme.primaryText]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Theme.accent
    }

    private func setupTableView() {
        tableView.backgroundColor = Theme.background
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        themeOptions.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Appearance"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        let option = themeOptions[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = option.title
        content.textProperties.color = Theme.primaryText
        cell.contentConfiguration = content
        cell.backgroundColor = Theme.cellBackground
        cell.accessoryType = Theme.currentMode == option.style ? .checkmark : .none
        cell.tintColor = Theme.accent
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Theme.currentMode = themeOptions[indexPath.row].style
        view.backgroundColor = Theme.background
        tableView.backgroundColor = Theme.background
        setupNavigationBar()
        tableView.reloadData()
    }
}

