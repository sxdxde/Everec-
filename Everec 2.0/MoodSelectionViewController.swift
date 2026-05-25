import UIKit

class MoodSelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.backButtonDisplayMode = .minimal
        setupNavigationBar()
        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.background
        appearance.titleTextAttributes = [.foregroundColor: Theme.primaryText]
        appearance.largeTitleTextAttributes = [.foregroundColor: Theme.primaryText]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Theme.accent
        navigationItem.title = "Everec"
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "How are you feeling?"
        titleLabel.font = .italicSystemFont(ofSize: 30)
        titleLabel.textColor = Theme.primaryText
        titleLabel.textAlignment = .center

        let happyButton = createMoodButton(mood: ":)", description: "Feeling good")
        happyButton.addTarget(self, action: #selector(happyTapped), for: .touchUpInside)

        let mehButton = createMoodButton(mood: ":/", description: "Could be better")
        mehButton.addTarget(self, action: #selector(mehTapped), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [happyButton, mehButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 30
        buttonStack.alignment = .center

        [titleLabel, buttonStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),

            happyButton.widthAnchor.constraint(equalToConstant: 250),
            happyButton.heightAnchor.constraint(equalToConstant: 120),
            mehButton.widthAnchor.constraint(equalToConstant: 250),
            mehButton.heightAnchor.constraint(equalToConstant: 120),
        ])
    }

    private func createMoodButton(mood: String, description: String) -> UIButton {
        let button = UIButton(type: .system)

        let moodLabel = UILabel()
        moodLabel.text = mood
        moodLabel.font = .systemFont(ofSize: 40)
        moodLabel.textColor = Theme.primaryText

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 15)
        descLabel.textColor = Theme.accent.withAlphaComponent(0.7)

        let stack = UIStackView(arrangedSubviews: [moodLabel, descLabel])
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
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1.5
        button.layer.borderColor = Theme.tint.cgColor

        return button
    }

    @objc private func happyTapped() {
        navigateToRecording(mood: ":)")
    }

    @objc private func mehTapped() {
        navigateToRecording(mood: ":/")
    }

    private func navigateToRecording(mood: String) {
        let recordingVC = RecordingViewController()
        recordingVC.mood = mood
        navigationController?.pushViewController(recordingVC, animated: true)
    }
}
