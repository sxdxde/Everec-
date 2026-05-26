import UIKit

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
        setupNavigationBar()
        setupTableView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupNavigationBar() {
        navigationItem.title = "Settings"

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
        tableView.separatorColor = Theme.tint.withAlphaComponent(0.2)
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

    private func applyCurrentColors(to cell: UITableViewCell) {
        cell.backgroundColor = Theme.cellBackground
        cell.textLabel?.textColor = Theme.primaryText
        cell.detailTextLabel?.textColor = Theme.tint
        cell.tintColor = Theme.accent
    }

    private func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")

        let alert = UIAlertController(
            title: "Onboarding Reset",
            message: "You will see onboarding the next time the app starts.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? themeOptions.count : 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Appearance" : "Onboarding"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.textProperties.color = Theme.primaryText

        if indexPath.section == 0 {
            let option = themeOptions[indexPath.row]
            content.text = option.title
            cell.accessoryType = Theme.currentMode == option.style ? .checkmark : .none
            cell.selectionStyle = .default
        } else {
            content.text = "Reset Onboarding"
            cell.accessoryType = .none
            cell.selectionStyle = .default
        }

        cell.contentConfiguration = content
        applyCurrentColors(to: cell)
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            Theme.currentMode = themeOptions[indexPath.row].style
            view.backgroundColor = Theme.background
            tableView.backgroundColor = Theme.background
            setupNavigationBar()
            tableView.reloadData()
        } else {
            resetOnboarding()
        }
    }
}
