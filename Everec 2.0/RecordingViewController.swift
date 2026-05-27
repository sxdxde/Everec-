import UIKit
import AVFoundation

class RecordingViewController: UIViewController {

    var mood: String = ":)"

    private let store = JournalStore.shared
    private var audioRecorder: AVAudioRecorder?
    private var currentRecordingURL: URL?
    private var currentFileName: String?
    private var recordingTimer: Timer?
    private var recordingDuration: TimeInterval = 0

    private let moodIconView = UIImageView()
    private let recordButton = UIButton(type: .custom)
    private let timerLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateLabel = UILabel()
    private let recordingDot = UIView()

    private var entries: [JournalEntry] {
        store.allEntries().filter { $0.mood == mood }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        setupNavigationBar()
        setupAudioSession()
        checkPermissions()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateEmptyState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if audioRecorder != nil {
            _ = finishRecording()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.background
        appearance.titleTextAttributes = [.foregroundColor: Theme.primaryText]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Theme.accent
        navigationItem.title = "Record"
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            showAlert(title: "Audio Error", message: "Could not configure audio session.")
        }
    }

    private func checkPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if !granted {
                    self?.recordButton.isEnabled = false
                    self?.recordButton.alpha = 0.4
                    self?.showAlert(
                        title: "Microphone Access Required",
                        message: "Please enable microphone access in Settings to record journal entries."
                    )
                }
            }
        }
    }

    private func setupUI() {
        let moodType = Mood(rawValue: mood)
        moodIconView.image = moodType?.icon(pointSize: 48, weight: .light)
        moodIconView.tintColor = moodType?.color ?? Theme.accent
        moodIconView.contentMode = .scaleAspectFit

        recordButton.backgroundColor = Theme.tint
        recordButton.layer.cornerRadius = 40
        recordButton.layer.borderWidth = 3
        recordButton.layer.borderColor = Theme.accent.cgColor
        recordButton.setImage(micImage(), for: .normal)
        recordButton.tintColor = .white
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)

        recordingDot.backgroundColor = .systemRed
        recordingDot.layer.cornerRadius = 5
        recordingDot.isHidden = true

        timerLabel.text = "Tap to record"
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 18, weight: .medium)
        timerLabel.textColor = Theme.accent
        timerLabel.textAlignment = .center

        let entriesHeader = UILabel()
        entriesHeader.text = "\(moodType?.label ?? mood) Entries"
        entriesHeader.font = .systemFont(ofSize: 18, weight: .semibold)
        entriesHeader.textColor = Theme.primaryText

        let separator = UIView()
        separator.backgroundColor = Theme.tint.withAlphaComponent(0.3)

        tableView.backgroundColor = Theme.background
        tableView.separatorColor = Theme.tint.withAlphaComponent(0.2)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(JournalEntryCell.self, forCellReuseIdentifier: "JournalEntryCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        emptyStateLabel.text = "No entries yet.\nTap the record button to start journaling."
        emptyStateLabel.font = .systemFont(ofSize: 15)
        emptyStateLabel.textColor = Theme.tint
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = !entries.isEmpty

        [moodIconView, recordButton, recordingDot, timerLabel,
         entriesHeader, separator, tableView, emptyStateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            moodIconView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            moodIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moodIconView.widthAnchor.constraint(equalToConstant: 56),
            moodIconView.heightAnchor.constraint(equalToConstant: 56),

            recordButton.topAnchor.constraint(equalTo: moodIconView.bottomAnchor, constant: 16),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80),

            recordingDot.widthAnchor.constraint(equalToConstant: 10),
            recordingDot.heightAnchor.constraint(equalToConstant: 10),
            recordingDot.centerYAnchor.constraint(equalTo: timerLabel.centerYAnchor),
            recordingDot.trailingAnchor.constraint(equalTo: timerLabel.leadingAnchor, constant: -8),

            timerLabel.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 10),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            entriesHeader.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 24),
            entriesHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            separator.topAnchor.constraint(equalTo: entriesHeader.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            separator.heightAnchor.constraint(equalToConstant: 1),

            tableView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 60),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
    }

    private func micImage() -> UIImage? {
        UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .medium))
    }

    private func stopImage() -> UIImage? {
        UIImage(systemName: "stop.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
    }

    // MARK: - Recording

    @objc private func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            if let entry = finishRecording() {
                let detailVC = JournalEntryDetailViewController()
                detailVC.entry = entry
                detailVC.isNewEntry = true
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }

    private func startRecording() {
        let fileName = "Recording_\(UUID().uuidString).m4a"
        let fileURL = store.audioDirectory.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            currentRecordingURL = fileURL
            currentFileName = fileName
            recordingDuration = 0

            recordButton.backgroundColor = .systemRed
            recordButton.layer.borderColor = UIColor.systemRed.cgColor
            recordButton.setImage(stopImage(), for: .normal)
            recordingDot.isHidden = false
            startPulsingAnimation()
            startTimer()
        } catch {
            showAlert(title: "Recording Failed", message: error.localizedDescription)
        }
    }

    @discardableResult
    private func finishRecording() -> JournalEntry? {
        audioRecorder?.stop()
        audioRecorder = nil
        stopTimer()
        resetRecordingUI()

        guard let fileName = currentFileName else { return nil }

        let entry = JournalEntry(mood: mood, date: Date(), audioFileName: fileName)
        store.addEntry(entry)

        currentFileName = nil
        currentRecordingURL = nil

        updateEmptyState()
        tableView.reloadData()

        return entry
    }

    private func resetRecordingUI() {
        recordButton.backgroundColor = Theme.tint
        recordButton.layer.borderColor = Theme.accent.cgColor
        recordButton.setImage(micImage(), for: .normal)
        recordingDot.isHidden = true
        recordingDot.layer.removeAllAnimations()
        timerLabel.text = "Tap to record"
    }

    // MARK: - Timer

    private func startTimer() {
        timerLabel.text = "00:00"
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.recordingDuration += 1
            let minutes = Int(self.recordingDuration) / 60
            let seconds = Int(self.recordingDuration) % 60
            self.timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private func startPulsingAnimation() {
        recordingDot.alpha = 1.0
        UIView.animate(withDuration: 0.8, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction]) {
            self.recordingDot.alpha = 0.2
        }
    }

    // MARK: - Helpers

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !entries.isEmpty
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AVAudioRecorderDelegate

extension RecordingViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            showAlert(title: "Recording Error", message: "Recording did not complete successfully.")
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension RecordingViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalEntryCell", for: indexPath) as! JournalEntryCell
        cell.configure(with: entries[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = JournalEntryDetailViewController()
        detailVC.entry = entries[indexPath.row]
        detailVC.isNewEntry = false
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = entries[indexPath.row]
            store.deleteEntry(id: entry.id)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateEmptyState()
        }
    }
}
