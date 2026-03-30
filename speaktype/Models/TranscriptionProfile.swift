import Foundation

enum TranscriptionProfile: String, CaseIterable, Identifiable, Codable {
    case prose
    case terminal
    case code
    case brainstorm

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .prose: return "Prose"
        case .terminal: return "Terminal"
        case .code: return "Code"
        case .brainstorm: return "Brainstorm"
        }
    }

    var description: String {
        switch self {
        case .prose:
            return "Natural dictation with normal sentence behavior."
        case .terminal:
            return "Optimized for shell commands, flags, paths, and CLI tools."
        case .code:
            return "Optimized for symbols, casing transforms, and technical identifiers."
        case .brainstorm:
            return "Technical prose with lighter cleanup and less aggressive command rewriting."
        }
    }

    static let allProfiles = Set(Self.allCases)
}

enum PunctuationMode: String, CaseIterable, Identifiable, Codable {
    case automatic
    case on
    case off

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .automatic: return "Automatic"
        case .on: return "On"
        case .off: return "Off"
        }
    }

    var description: String {
        switch self {
        case .automatic:
            return "Uses profile defaults: prose on, developer-oriented modes off."
        case .on:
            return "Keeps punctuation and converts spoken punctuation words."
        case .off:
            return "Skips sentence punctuation and ignores spoken punctuation words."
        }
    }

    func resolved(for profile: TranscriptionProfile) -> Bool {
        switch self {
        case .on:
            return true
        case .off:
            return false
        case .automatic:
            return profile == .prose
        }
    }
}
