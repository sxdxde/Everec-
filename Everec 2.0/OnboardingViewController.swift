import UIKit

class OnboardingViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let startButton = UIButton(type: .system)

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("waveform.circle.fill", "Welcome to Everec", "Your personal voice journal.\nCapture your thoughts by speaking,\nnot typing."),
        ("mic.fill", "Record & Transcribe", "Tap to record your thoughts.\nEverec automatically transcribes\nyour voice into text."),
        ("chart.bar.fill", "Track Your Mood", "Choose how you feel before each entry.\nSee insights and patterns\nover time."),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupUI() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false

        pageControl.numberOfPages = pages.count
        pageControl.currentPageIndicatorTintColor = Theme.accent
        pageControl.pageIndicatorTintColor = Theme.tint.withAlphaComponent(0.3)
        pageControl.addTarget(self, action: #selector(pageChanged), for: .valueChanged)

        startButton.setTitle("Get Started", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        startButton.setTitleColor(Theme.background, for: .normal)
        startButton.backgroundColor = Theme.accent
        startButton.layer.cornerRadius = 25

        let nextButton = UIButton(type: .system)
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        nextButton.setTitleColor(Theme.accent, for: .normal)
        nextButton.tag = 1
        nextButton.addTarget(self, action: #selector(nextTapped(_:)), for: .touchUpInside)

        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        startButton.alpha = 0

        [scrollView, pageControl, startButton, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -24),

            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),

            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -52),
        ])

        self.nextButton = nextButton
    }

    private weak var nextButton: UIButton?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let w = scrollView.bounds.width
        let h = scrollView.bounds.height
        guard w > 0 else { return }
        scrollView.contentSize = CGSize(width: w * CGFloat(pages.count), height: h)

        scrollView.subviews.filter { $0.tag >= 100 }.forEach { $0.removeFromSuperview() }

        for (i, page) in pages.enumerated() {
            let container = UIView(frame: CGRect(x: w * CGFloat(i), y: 0, width: w, height: h))
            container.tag = 100 + i

            let icon = UIImageView(image: UIImage(systemName: page.icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 60, weight: .light)))
            icon.tintColor = Theme.accent
            icon.contentMode = .scaleAspectFit

            let title = UILabel()
            title.text = page.title
            title.font = .systemFont(ofSize: 32, weight: .bold)
            title.textColor = Theme.primaryText
            title.textAlignment = .center

            let subtitle = UILabel()
            subtitle.text = page.subtitle
            subtitle.font = .systemFont(ofSize: 17)
            subtitle.textColor = Theme.accent.withAlphaComponent(0.7)
            subtitle.textAlignment = .center
            subtitle.numberOfLines = 0

            let stack = UIStackView(arrangedSubviews: [icon, title, subtitle])
            stack.axis = .vertical
            stack.spacing = 20
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(stack)

            NSLayoutConstraint.activate([
                stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                stack.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -20),
                stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 40),
                stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -40),
            ])

            scrollView.addSubview(container)
        }
    }

    @objc private func pageChanged() {
        let x = scrollView.bounds.width * CGFloat(pageControl.currentPage)
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        updateButtons()
    }

    @objc private func nextTapped(_ sender: UIButton) {
        let next = pageControl.currentPage + 1
        guard next < pages.count else { return }
        let x = scrollView.bounds.width * CGFloat(next)
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    @objc private func startTapped() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        let moodVC = MoodSelectionViewController()
        navigationController?.setViewControllers([moodVC], animated: true)
    }

    private func updateButtons() {
        let isLast = pageControl.currentPage == pages.count - 1
        UIView.animate(withDuration: 0.25) {
            self.startButton.alpha = isLast ? 1 : 0
            self.nextButton?.alpha = isLast ? 0 : 1
        }
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.bounds.width > 0 else { return }
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        pageControl.currentPage = page
        updateButtons()
    }
}
