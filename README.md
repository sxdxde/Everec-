# Everec 2.0

Everec 2.0 is an iOS voice journaling app built with UIKit. The app helps users quickly capture a journal entry by choosing a mood, recording audio, and reviewing an automatically generated transcript. Entries are stored locally on device with their mood, recording file, title, transcript, tags, and date.

## Features

- Mood-first journaling flow with six selectable moods: Happy, Calm, Anxious, Sad, Angry, and Neutral.
- Voice recording using `AVAudioRecorder`.
- Local playback for saved recordings using `AVAudioPlayer`.
- Speech-to-text transcription using Apple's Speech framework.
- Editable journal detail screen with title and transcript editing.
- Tag chips for organizing entries.
- Local JSON persistence for entry metadata.
- Local file storage for audio recordings.
- Journal list with empty state, formatted dates, tags, and mood indicators.
- Analytics screen with total entries, current streak, and 30-day mood counts.
- Appearance settings for System, Light, and Dark mode.
- Onboarding flow for first-time users.

## Tech Stack

- Language: Swift
- UI framework: UIKit
- App lifecycle: `UIApplicationDelegate` and `UISceneDelegate`
- Audio recording and playback: AVFoundation
- Speech recognition: Speech
- Persistence: `Codable`, JSON file storage, and app Documents directory
- Project format: Xcode iOS app project

## Requirements

- macOS with Xcode installed
- iOS Simulator or physical iOS device
- Microphone permission for recording
- Speech Recognition permission for transcription

Speech recognition availability can vary by simulator/device, language, and system settings. Recording works best on a physical device with microphone access enabled.

## Getting Started

1. Open `Everec 2.0.xcodeproj` in Xcode.
2. Select the `Everec 2.0` scheme.
3. Choose an iOS Simulator or connected device.
4. Build and run with `Cmd + R`.
5. Complete onboarding, choose a mood, and tap the microphone button to start a journal recording.

## Permissions

The app declares the required privacy usage descriptions in `Info.plist`:

- `NSMicrophoneUsageDescription`: required for recording voice journal entries.
- `NSSpeechRecognitionUsageDescription`: required for transcribing recordings into text.

If either permission is denied, the related feature will not work until permission is restored in iOS Settings.

## Project Structure

```text
Everec 2.0/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Info.plist
├── Theme.swift
├── Mood.swift
├── JournalEntry.swift
├── JournalStore.swift
├── OnboardingViewController.swift
├── MoodSelectionViewController.swift
├── RecordingViewController.swift
├── JournalEntryDetailViewController.swift
├── JournalEntryCell.swift
├── WaveformView.swift
├── TagsInputView.swift
├── FormattingToolbar.swift
├── Assets.xcassets
├── Base.lproj/
│   ├── Main.storyboard
│   └── LaunchScreen.storyboard
├── AnalyticsViewController.swift
└── SettingsViewController.swift
```

## Main Components

### AppDelegate.swift

Standard app delegate entry point for application-level lifecycle events.

### SceneDelegate.swift

Creates the root window and chooses the starting screen:

- `OnboardingViewController` for first launch.
- `MoodSelectionViewController` after onboarding is complete.

The root view controller is embedded in a `UINavigationController`.

### Theme.swift

Centralizes app colors and appearance mode handling. `Theme.currentMode` stores the selected interface style in `UserDefaults`, and `Theme.applyTheme()` applies it to active app windows.

### Mood.swift

Defines the supported mood cases and their display properties:

- Raw value for storage.
- Emoji for UI display.
- Human-readable label.
- UIKit color for mood accents.

### JournalEntry.swift

The app's persisted journal model. Each entry includes:

- Unique ID
- Mood
- Date
- Audio file name
- Optional title
- Optional transcription
- Tags
- Optional formatted transcription data

### JournalStore.swift

Singleton data store responsible for loading, saving, updating, searching, and deleting journal entries.

Entry metadata is saved to:

```text
Documents/journal_entries.json
```

Audio files are saved to:

```text
Documents/Recordings/
```

The store also exposes helper methods for mood counts and current journaling streak.

### OnboardingViewController.swift

Displays the first-run onboarding pages and marks onboarding complete in `UserDefaults` using the `hasCompletedOnboarding` key.

### MoodSelectionViewController.swift

The main mood selection screen. Users choose a mood before creating a recording. The navigation bar also exposes analytics and settings actions.

### RecordingViewController.swift

Handles recording flow:

- Requests microphone permission.
- Configures the audio session.
- Starts and stops `AVAudioRecorder`.
- Saves new entries to `JournalStore`.
- Displays existing journal entries in a table view.
- Opens `JournalEntryDetailViewController` for playback, transcription, and editing.

### JournalEntryDetailViewController.swift

Displays and edits an individual entry. It supports:

- Audio playback.
- Automatic speech transcription for new entries.
- Manual transcript editing.
- Title editing.
- Saving changes on exit.

### JournalEntryCell.swift

Custom table view cell for journal list rows. Shows mood, title, date, transcript preview, and tag chips.

### TagsInputView.swift

Reusable tag input view with add/remove chip behavior.

### FormattingToolbar.swift

Input accessory toolbar for transcript formatting controls such as bold, italic, highlight, and Done.

### AnalyticsViewController.swift

Displays basic journal statistics, including total entries, current streak, and recent mood counts.

### SettingsViewController.swift

Displays app settings, including appearance selection for System, Light, and Dark mode.

## Data Flow

1. User completes onboarding.
2. User selects a mood.
3. `MoodSelectionViewController` opens `RecordingViewController`.
4. User records audio.
5. `RecordingViewController` saves an `.m4a` file in `Documents/Recordings/`.
6. A `JournalEntry` is added to `JournalStore`.
7. `JournalStore` writes entry metadata to `journal_entries.json`.
8. `JournalEntryDetailViewController` opens and starts transcription for new entries.
9. User can edit title/transcript/tags and return to the journal list.

## Local Storage

Everec currently stores all data locally in the app sandbox. There is no backend service, account system, or cloud sync.

Deleting an entry removes both:

- The JSON metadata record.
- The associated audio file from the recordings directory.

Uninstalling the app removes locally stored journal data unless the device restores app container data from a backup.

## Build and Verification

From Xcode:

1. Open the project.
2. Select the `Everec 2.0` scheme.
3. Build with `Cmd + B`.

The project was last verified with Xcode's build system and completed successfully.

## Common Issues

### Microphone permission denied

Recording is disabled if microphone access is denied. Re-enable it in:

```text
Settings > Privacy & Security > Microphone
```

### Speech recognition permission denied

Transcription will fail if Speech Recognition access is denied. Re-enable it in:

```text
Settings > Privacy & Security > Speech Recognition
```

### Speech recognizer unavailable

The speech recognizer can be unavailable because of simulator limitations, language settings, network/system conditions, or device restrictions. The app allows users to type transcript text manually when transcription fails.

## Current Limitations

- Data is local-only.
- No iCloud sync or backup UI.
- No authentication or multi-user support.
- No automated test target is currently documented.
- Speech transcription uses Apple's default recognizer availability and does not provide custom language selection.

## Future Improvements

- Add search and filter UI using the existing `JournalStore.search(text:mood:)` support.
- Add export options for audio and transcripts.
- Add iCloud sync.
- Add unit tests for `JournalStore`, streak calculation, and mood analytics.
- Add UI tests for onboarding, recording, and entry editing flows.
- Move analytics and settings into standalone compiled source files if the project target membership is cleaned up.

## Privacy Notes

Journal entries and recordings can contain sensitive personal information. The current implementation stores data locally in the app sandbox and does not upload entries to a server. Any future sync, sharing, analytics, or export feature should preserve this privacy expectation and clearly disclose where data is stored.
