import UIKit

class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Everec"
        titleLabel.font = .systemFont(ofSize: 48, weight: .bold)
        titleLabel.textColor = Theme.primaryText
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Your Voice Journal"
        subtitleLabel.font = .italicSystemFont(ofSize: 20)
        subtitleLabel.textColor = Theme.accent
        subtitleLabel.textAlignment = .center

        let descLabel = UILabel()
        descLabel.text = "Everec is a daily journal app that\nlets you record your thoughts\ninstead of writing them down."
        descLabel.font = .systemFont(ofSize: 17)
        descLabel.textColor = Theme.accent.withAlphaComponent(0.7)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0

        let startButton = UIButton(type: .system)
        startButton.setTitle("Get Started", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        startButton.setTitleColor(Theme.background, for: .normal)
        startButton.backgroundColor = Theme.accent
        startButton.layer.cornerRadius = 25
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 8
        headerStack.alignment = .center

        [headerStack, descLabel, startButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            headerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),

            descLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 30),
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    @objc private func startTapped() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        let moodVC = MoodSelectionViewController()
        navigationController?.pushViewController(moodVC, animated: true)
    }
}
