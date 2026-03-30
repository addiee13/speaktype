import XCTest
@testable import speaktype

final class CustomDictionaryServiceTests: XCTestCase {
    func testAppliesRequestedTechTerms() {
        let output = CustomDictionaryService.shared.apply(
            to: "chat gpt claude gemini next auth fast api"
        )

        XCTAssertEqual(output, "ChatGPT Claude Gemini NextAuth FastAPI")
    }

    func testAppliesTermsInsideSentence() {
        let output = CustomDictionaryService.shared.apply(
            to: "build this with chatgpt and next-auth on fastapi"
        )

        XCTAssertEqual(output, "build this with ChatGPT and NextAuth on FastAPI")
    }

    func testAppliesAdditionalTechCasing() {
        let output = CustomDictionaryService.shared.apply(
            to: "open ai with github typescript and node js"
        )

        XCTAssertEqual(output, "OpenAI with GitHub TypeScript and Node.js")
    }

    func testNormalizedTranscriptionAlsoAppliesDictionary() {
        let output = WhisperService.normalizedTranscription(
            from: " [BLANK_AUDIO] chat gpt with next auth and fast api "
        )

        XCTAssertEqual(output, "ChatGPT with NextAuth and FastAPI")
    }

    func testFormatsCompanyNamesWithCorrectPunctuation() {
        let output = CustomDictionaryService.shared.formatForOutput(
            "open ai with git hub on next js and node js",
            profile: .prose,
            punctuationMode: .on,
            bundleIdentifier: nil
        )

        XCTAssertEqual(output, "OpenAI with GitHub on Next.js and Node.js")
    }

    func testTerminalAdaptationNormalizesKnownSingleWordCommand() {
        let output = CustomDictionaryService.shared.formatForOutput(
            "Codex.",
            profile: .terminal,
            punctuationMode: .off,
            bundleIdentifier: "com.apple.Terminal"
        )

        XCTAssertEqual(output, "codex")
    }

    func testTerminalAdaptationNormalizesKnownCommandPrefix() {
        let output = CustomDictionaryService.shared.formatForOutput(
            "Git status.",
            profile: .terminal,
            punctuationMode: .off,
            bundleIdentifier: "com.apple.Terminal"
        )

        XCTAssertEqual(output, "git status")
    }

    func testPunctuationOffStripsSentencePunctuationButKeepsTechTerms() {
        let output = CustomDictionaryService.shared.formatForOutput(
            "open ai comma next js period",
            profile: .prose,
            punctuationMode: .off,
            bundleIdentifier: nil
        )

        XCTAssertEqual(output, "OpenAI Next.js")
    }

    func testCodeProfileSupportsCasingTransforms() {
        let output = CustomDictionaryService.shared.formatForOutput(
            "camel case user id",
            profile: .code,
            punctuationMode: .off,
            bundleIdentifier: nil
        )

        XCTAssertEqual(output, "userId")
    }

    func testTerminalProfileFormatsCommonFlagPhrases() {
        let output = CustomDictionaryService.shared.formatForOutput(
            "npm install dash dash save dev typescript",
            profile: .terminal,
            punctuationMode: .off,
            bundleIdentifier: "com.apple.Terminal"
        )

        XCTAssertEqual(output, "npm install --save-dev typescript")
    }

    func testProfileResolverDetectsTerminalApps() {
        let profile = CustomDictionaryService.shared.resolveProfile(
            preferredRawValue: TranscriptionProfile.prose.rawValue,
            autoDetect: true,
            bundleIdentifier: "com.apple.Terminal"
        )

        XCTAssertEqual(profile, .terminal)
    }

    func testBuiltInLexiconHasLargeVocabulary() {
        XCTAssertGreaterThan(DeveloperLexicon.shared.entries.count, 800)
    }
}
