import UIKit
import AVFoundation
import Speech

class JournalEntryDetailViewController: UIViewController {

    var entry: JournalEntry!
    var isNewEntry = false

    private let store = JournalStore.shared
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false

    private let moodDateLabel = UILabel()
    private let titleField = UITextField()
    private let playButton = UIButton()
    private let transcriptHeader = UILabel()
    private let transcriptView = UITextView()
    private let transcribingSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        setupNavigationBar()
        setupUI()
        populateData()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        if isNewEntry && entry.transcription == nil {
            startTranscription()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPlayback()
        saveEntry()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationItem.title = isNewEntry ? "New Entry" : "Journal Entry"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.background
        appearance.titleTextAttributes = [.foregroundColor: Theme.primaryText]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Theme.accent
    }

    private func setupUI() {
        moodDateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        moodDateLabel.textColor = Theme.accent

        titleField.font = .systemFont(ofSize: 26, weight: .bold)
        titleField.textColor = Theme.primaryText
        titleField.attributedPlaceholder = NSAttributedString(
            string: "Entry title...",
            attributes: [.foregroundColor: Theme.tint.withAlphaComponent(0.4)]
        )
        titleField.borderStyle = .none
        titleField.returnKeyType = .done
        titleField.delegate = self

        var playConfig = UIButton.Configuration.filled()
        playConfig.image = UIImage(systemName: "play.fill")
        playConfig.title = "Play Recording"
        playConfig.baseForegroundColor = Theme.accent
        playConfig.baseBackgroundColor = Theme.cellBackground
        playConfig.cornerStyle = .medium
        playConfig.imagePadding = 6
        playConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        playConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            return outgoing
        }
        playButton.configuration = playConfig
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        transcriptHeader.text = "Transcript"
        transcriptHeader.font = .systemFont(ofSize: 14, weight: .semibold)
        transcriptHeader.textColor = Theme.tint

        transcribingSpinner.color = Theme.accent
        transcribingSpinner.hidesWhenStopped = true

        transcriptView.font = .systemFont(ofSize: 16)
        transcriptView.textColor = Theme.primaryText
        transcriptView.backgroundColor = Theme.cellBackground
        transcriptView.layer.cornerRadius = 12
        transcriptView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        transcriptView.isEditable = true
        transcriptView.keyboardDismissMode = .interactive

        let separator = UIView()
        separator.backgroundColor = Theme.tint.withAlphaComponent(0.2)

        [moodDateLabel, titleField, separator, playButton,
         transcriptHeader, transcribingSpinner, transcriptView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            moodDateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            moodDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            moodDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            titleField.topAnchor.constraint(equalTo: moodDateLabel.bottomAnchor, constant: 12),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleField.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            separator.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            separator.heightAnchor.constraint(equalToConstant: 1),

            playButton.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16),
            playButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            transcriptHeader.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            transcriptHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            transcribingSpinner.centerYAnchor.constraint(equalTo: transcriptHeader.centerYAnchor),
            transcribingSpinner.leadingAnchor.constraint(equalTo: transcriptHeader.trailingAnchor, constant: 8),

            transcriptView.topAnchor.constraint(equalTo: transcriptHeader.bottomAnchor, constant: 8),
            transcriptView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            transcriptView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            transcriptView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -12),
        ])
    }

    private func populateData() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        moodDateLabel.text = "\(entry.mood)  \(formatter.string(from: entry.date))"

        titleField.text = entry.title

        if let transcription = entry.transcription, !transcription.isEmpty {
            transcriptView.text = transcription
        } else {
            transcriptView.text = ""
        }

        updatePlayButtonDuration()
    }

    private func updatePlayButtonDuration() {
        let audioURL = store.audioDirectory.appendingPathComponent(entry.audioFileName)
        guard let player = try? AVAudioPlayer(contentsOf: audioURL) else { return }
        let minutes = Int(player.duration) / 60
        let seconds = Int(player.duration) % 60
        let durationText = String(format: "%d:%02d", minutes, seconds)
        var config = playButton.configuration ?? UIButton.Configuration.filled()
        config.title = "Play Recording  \(durationText)"
        playButton.configuration = config
    }

    // MARK: - Transcription

    private func startTranscription() {
        transcribingSpinner.startAnimating()

        let audioURL = store.audioDirectory.appendingPathComponent(entry.audioFileName)
        let entryId = entry.id

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self?.transcribingSpinner.stopAnimating()
                }
                JournalStore.shared.updateTranscription(for: entryId, transcription: "")
                return
            }
            guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
                DispatchQueue.main.async {
                    self?.transcribingSpinner.stopAnimating()
                }
                JournalStore.shared.updateTranscription(for: entryId, transcription: "")
                return
            }
            let request = SFSpeechURLRecognitionRequest(url: audioURL)
            recognizer.recognitionTask(with: request) { [weak self] result, error in
                if let result, result.isFinal {
                    let text = result.bestTranscription.formattedString
                    DispatchQueue.main.async {
                        self?.transcribingSpinner.stopAnimating()
                        self?.transcriptView.text = text
                        self?.entry.transcription = text
                    }
                    JournalStore.shared.updateTranscription(for: entryId, transcription: text)
                } else if error != nil {
                    DispatchQueue.main.async {
                        self?.transcribingSpinner.stopAnimating()
                        self?.entry.transcription = ""
                    }
                    JournalStore.shared.updateTranscription(for: entryId, transcription: "")
                }
            }
        }
    }

    // MARK: - Playback

    @objc private func playTapped() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }

    private func startPlayback() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {}

        let audioURL = store.audioDirectory.appendingPathComponent(entry.audioFileName)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            updatePlayButtonState()
        } catch {
            let alert = UIAlertController(title: "Playback Failed", message: "Could not play this recording.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        updatePlayButtonState()
    }

    private func updatePlayButtonState() {
        var config = playButton.configuration ?? UIButton.Configuration.filled()
        config.image = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")

        let label = isPlaying ? "Pause" : "Play Recording"
        let audioURL = store.audioDirectory.appendingPathComponent(entry.audioFileName)
        if let player = try? AVAudioPlayer(contentsOf: audioURL) {
            let minutes = Int(player.duration) / 60
            let seconds = Int(player.duration) % 60
            config.title = "\(label)  \(String(format: "%d:%02d", minutes, seconds))"
        } else {
            config.title = label
        }
        playButton.configuration = config
    }

    // MARK: - Save

    private func saveEntry() {
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.title = (title?.isEmpty ?? true) ? nil : title
        entry.transcription = transcriptView.text
        store.updateEntry(entry)
    }
}

// MARK: - AVAudioPlayerDelegate

extension JournalEntryDetailViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        updatePlayButtonState()
    }
}

// MARK: - UITextFieldDelegate

extension JournalEntryDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
