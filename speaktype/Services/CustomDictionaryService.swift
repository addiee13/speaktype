import Foundation

struct CustomDictionaryRule: Codable, Hashable {
    let replacement: String
    let patterns: [String]
}

final class CustomDictionaryService {
    static let shared = CustomDictionaryService()

    private static let terminalBundleIdentifiers: Set<String> = [
        "com.apple.Terminal",
        "com.googlecode.iterm2",
        "dev.warp.Warp-Stable",
        "dev.warp.WarpPreview",
        "co.zeit.hyper",
        "net.kovidgoyal.kitty",
        "com.github.wez.wezterm",
        "org.alacritty",
    ]

    private static let codeBundleIdentifiers: Set<String> = [
        "com.microsoft.VSCode",
        "com.microsoft.VSCodeInsiders",
        "com.cursor.Cursor",
        "com.jetbrains.intellij",
        "com.jetbrains.pycharm",
        "com.jetbrains.datagrip",
        "com.jetbrains.WebStorm",
        "com.jetbrains.CLion",
        "com.apple.dt.Xcode",
        "com.sublimetext.4",
        "com.github.atom",
        "md.obsidian",
    ]

    private static let spokenPunctuationMap: [(phrase: String, replacement: String)] = [
        ("question mark", "?"),
        ("exclamation mark", "!"),
        ("open parenthesis", "("),
        ("close parenthesis", ")"),
        ("open bracket", "["),
        ("close bracket", "]"),
        ("open brace", "{"),
        ("close brace", "}"),
        ("semicolon", ";"),
        ("colon", ":"),
        ("comma", ","),
        ("period", "."),
        ("full stop", "."),
    ]

    private static let symbolCommandMap: [(phrase: String, replacement: String)] = [
        ("triple equals", "==="),
        ("double equals", "=="),
        ("not equals", "!="),
        ("strict not equals", "!=="),
        ("fat arrow", "=>"),
        ("arrow", "->"),
        ("dash dash", "--"),
        ("dot slash", "./"),
        ("slash", "/"),
        ("backslash", "\\"),
        ("pipe", "|"),
        ("ampersand", "&"),
        ("double ampersand", "&&"),
        ("colon", ":"),
        ("semicolon", ";"),
        ("comma", ","),
        ("period", "."),
        ("dot", "."),
        ("equals", "="),
        ("plus", "+"),
        ("minus", "-"),
        ("underscore", "_"),
    ]

    private static let sentencePunctuationWords = [
        "comma",
        "period",
        "full stop",
        "question mark",
        "exclamation mark",
        "colon",
        "semicolon",
    ]

    private init() {}

    var defaultRules: [CustomDictionaryRule] { [] }

    func apply(to text: String) -> String {
        applyLexicon(to: text, profile: .prose)
    }

    func resolveProfile(
        preferredRawValue: String,
        autoDetect: Bool,
        bundleIdentifier: String?
    ) -> TranscriptionProfile {
        let preferred = TranscriptionProfile(rawValue: preferredRawValue) ?? .prose
        guard autoDetect else { return preferred }

        if let detected = detectedProfile(for: bundleIdentifier) {
            return detected
        }

        return preferred
    }

    func detectedProfile(for bundleIdentifier: String?) -> TranscriptionProfile? {
        guard let bundleIdentifier else { return nil }
        if Self.terminalBundleIdentifiers.contains(bundleIdentifier) {
            return .terminal
        }
        if Self.codeBundleIdentifiers.contains(bundleIdentifier) {
            return .code
        }
        return nil
    }

    func formatForOutput(
        _ text: String,
        profile: TranscriptionProfile,
        punctuationMode: PunctuationMode,
        bundleIdentifier: String?
    ) -> String {
        guard !text.isEmpty else { return text }

        let punctuationEnabled = punctuationMode.resolved(for: profile)
        var updated = text.trimmingCharacters(in: .whitespacesAndNewlines)

        updated = applyLexicon(to: updated, profile: profile)
        updated = applyCaseTransformIfNeeded(to: updated, profile: profile)
        updated = applySymbolCommands(to: updated, profile: profile)
        updated = applyPunctuationMode(to: updated, punctuationEnabled: punctuationEnabled)
        updated = adaptForTargetApp(updated, profile: profile, bundleIdentifier: bundleIdentifier)
        updated = cleanupSpacing(in: updated)

        return updated
    }

    func adaptForTargetApp(
        _ text: String,
        profile: TranscriptionProfile,
        bundleIdentifier: String?
    ) -> String {
        let effectiveProfile = detectedProfile(for: bundleIdentifier) == .terminal ? .terminal : profile

        guard effectiveProfile == .terminal || effectiveProfile == .code else {
            return text
        }

        return normalizeShellCommandIfNeeded(text)
    }

    private func applyLexicon(to text: String, profile: TranscriptionProfile) -> String {
        guard !text.isEmpty else { return text }
        var updated = text

        for entry in DeveloperLexicon.shared.entries where entry.profiles.contains(profile) {
            for spokenVariant in entry.spokenVariants {
                let pattern = pattern(for: spokenVariant)
                updated = updated.replacingOccurrences(
                    of: pattern,
                    with: replacement(for: entry, profile: profile),
                    options: [.regularExpression, .caseInsensitive]
                )
            }
        }

        return updated
    }

    private func pattern(for spokenVariant: String) -> String {
        let tokens = spokenVariant
            .split(separator: " ")
            .map { NSRegularExpression.escapedPattern(for: String($0)) }

        guard !tokens.isEmpty else { return NSRegularExpression.escapedPattern(for: spokenVariant) }
        let joined = tokens.joined(separator: #"[\s._/\-]*"#)
        return #"(?<![A-Za-z0-9])"# + joined + #"(?![A-Za-z0-9])"#
    }

    private func replacement(for entry: DeveloperLexiconEntry, profile: TranscriptionProfile) -> String {
        guard profile == .terminal else { return entry.canonical }
        return entry.canonical.lowercased()
    }

    private func applySymbolCommands(to text: String, profile: TranscriptionProfile) -> String {
        guard profile == .terminal || profile == .code else { return text }

        var updated = text

        for mapping in Self.symbolCommandMap.sorted(by: { $0.phrase.count > $1.phrase.count }) {
            let pattern = pattern(for: mapping.phrase)
            updated = updated.replacingOccurrences(
                of: pattern,
                with: mapping.replacement,
                options: [.regularExpression, .caseInsensitive]
            )
        }

        updated = updated.replacingOccurrences(
            of: #"\s*/\s*"#,
            with: "/",
            options: .regularExpression
        )
        updated = updated.replacingOccurrences(
            of: #"\s*\\\s*"#,
            with: "\\",
            options: .regularExpression
        )
        updated = updated.replacingOccurrences(
            of: #"\s*\|\s*"#,
            with: " | ",
            options: .regularExpression
        )

        return updated
    }

    private func applyCaseTransformIfNeeded(to text: String, profile: TranscriptionProfile) -> String {
        guard profile == .code || profile == .terminal else { return text }

        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let commands: [(prefix: String, transform: ([String]) -> String)] = [
            ("camel case ", { words in
                guard let first = words.first?.lowercased() else { return "" }
                return first + words.dropFirst().map(capitalize).joined()
            }),
            ("pascal case ", { words in
                words.map(capitalize).joined()
            }),
            ("snake case ", { words in
                words.map { $0.lowercased() }.joined(separator: "_")
            }),
            ("kebab case ", { words in
                words.map { $0.lowercased() }.joined(separator: "-")
            })
        ]

        let lowercased = normalized.lowercased()
        for command in commands where lowercased.hasPrefix(command.prefix) {
            let payload = String(normalized.dropFirst(command.prefix.count))
            let words = payload
                .split(whereSeparator: { $0.isWhitespace || $0 == "-" || $0 == "_" })
                .map(String.init)
                .filter { !$0.isEmpty }
            guard !words.isEmpty else { return normalized }
            return command.transform(words)
        }

        return normalized
    }

    private func applyPunctuationMode(to text: String, punctuationEnabled: Bool) -> String {
        var updated = text

        if punctuationEnabled {
            for mapping in Self.spokenPunctuationMap.sorted(by: { $0.phrase.count > $1.phrase.count }) {
                let pattern = pattern(for: mapping.phrase)
                updated = updated.replacingOccurrences(
                    of: pattern,
                    with: mapping.replacement,
                    options: [.regularExpression, .caseInsensitive]
                )
            }
            return cleanupSpacing(in: updated)
        }

        for word in Self.sentencePunctuationWords.sorted(by: { $0.count > $1.count }) {
            updated = updated.replacingOccurrences(
                of: pattern(for: word),
                with: " ",
                options: [.regularExpression, .caseInsensitive]
            )
        }

        updated = updated.replacingOccurrences(
            of: #"[.,!?;:]+(?=(?:\s|$))"#,
            with: "",
            options: .regularExpression
        )

        return cleanupSpacing(in: updated)
    }

    private func normalizeShellCommandIfNeeded(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }

        let parts = trimmed.split(separator: " ", omittingEmptySubsequences: true)
        guard let firstPart = parts.first else { return text }

        let normalizedHead = DeveloperLexicon.commandHeadForm(for: String(firstPart))
        guard DeveloperLexicon.shared.commandHeadTerms.contains(normalizedHead) else {
            return trimmed
        }

        let strippedTrailingPunctuation = trimmed.replacingOccurrences(
            of: #"[.!?,:;]+$"#,
            with: "",
            options: .regularExpression
        )

        if parts.count == 1 {
            return normalizedHead
        }

        let tokenRange = strippedTrailingPunctuation.startIndex..<firstPart.endIndex
        return strippedTrailingPunctuation.replacingCharacters(in: tokenRange, with: normalizedHead)
    }

    private func cleanupSpacing(in text: String) -> String {
        var updated = text

        updated = updated.replacingOccurrences(
            of: #"\s+"#,
            with: " ",
            options: .regularExpression
        )
        updated = updated.replacingOccurrences(
            of: #"\s+([,.;:!?])"#,
            with: "$1",
            options: .regularExpression
        )
        updated = updated.replacingOccurrences(
            of: #"([(/[{])\s+"#,
            with: "$1",
            options: .regularExpression
        )
        updated = updated.replacingOccurrences(
            of: #"\s+([)\]}])"#,
            with: "$1",
            options: .regularExpression
        )
        updated = updated.replacingOccurrences(
            of: #"\s*=\s*"#,
            with: " = ",
            options: .regularExpression
        )

        return updated.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private func capitalize(_ value: String) -> String {
    guard let first = value.first else { return value }
    return String(first).uppercased() + value.dropFirst().lowercased()
}
