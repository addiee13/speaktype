# Developer-First SpeakType Plan

## Goal
Turn SpeakType into a developer-focused dictation app that works well for terminal commands, code-oriented speech, and technical brainstorming while preserving the current offline/local positioning.

## Success Criteria
- Terminal dictation produces executable commands instead of sentence-style prose.
- Technical company names, package names, and developer vocabulary are normalized with correct casing and punctuation.
- Users can choose between `Prose`, `Terminal`, `Code`, and `Brainstorm` output profiles.
- Users can toggle punctuation behavior so dictation can stay plain by default and only add punctuation when enabled.
- History preserves enough metadata to debug normalization choices.

## Implementation Tasks
### 1. Output Profiles
- Add `TranscriptionProfile` enum and persist the selected profile.
- Auto-detect terminal and editor apps from the foreground bundle identifier.
- Show the active profile in settings and recorder UI.

### 2. Punctuation Control
- Add `PunctuationMode` enum with `automatic`, `on`, and `off`.
- Default punctuation to `on` for prose and `off` for developer-oriented profiles when using automatic mode.
- Ignore spoken punctuation words when punctuation is off.

### 3. Developer Lexicon
- Replace the small regex list with a large structured built-in lexicon.
- Include shell commands, CLIs, languages, frameworks, packages, infra terms, protocols, and company names.
- Keep the lexicon local and data-driven enough to keep expanding.

### 4. Profile-Aware Formatting
- Apply raw cleanup, vocabulary normalization, casing transforms, symbol commands, punctuation handling, and target-app adaptation in explicit stages.
- Lowercase command heads and command-oriented vocabulary in terminal mode.
- Support spoken symbol phrases and casing transforms for code mode.

### 5. Persistence and Observability
- Store raw transcript, formatted transcript, profile, punctuation mode, and target app in history.
- Keep existing history entries readable through migration-friendly defaults.

### 6. Follow-Up Iterations
- Add user-editable custom vocabulary and rule management.
- Add more symbol/flag phrases and package ecosystems.
- Tune output using real dictation samples from terminals, editors, and chat apps.

## Current Iteration
- Profile system implemented.
- Punctuation mode implemented.
- Large built-in developer lexicon implemented.
- Terminal-aware formatting and safer command output implemented.
- Settings and recorder controls implemented.
- History metadata extended.

## Remaining Work
- Custom vocabulary UI and persistence.
- More spoken symbol coverage for code-heavy dictation.
- Broader manual QA on real macOS targets.
- Full test/build verification in an environment with `xcodebuild`.
