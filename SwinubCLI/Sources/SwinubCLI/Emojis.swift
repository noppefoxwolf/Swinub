import ArgumentParser
import Foundation
import Swinub

struct Emojis: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "emojis",
        abstract: "Fetch custom emojis from an instance."
    )

    @Option(help: "Instance host, for example mastodon.social.")
    var host: String

    @Flag(help: "Print raw JSON.")
    var json = false

    mutating func run() async throws {
        let emojis = try await SwinubDefaults.session.response(
            for: GetV1CustomEmojis(host: host)
        ).response

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(emojis)
            guard let output = String(data: data, encoding: .utf8) else {
                throw ValidationError("Failed to encode emojis as JSON.")
            }
            print(output)
        } else {
            print("count: \(emojis.count)")
            for emoji in emojis.prefix(20) {
                print(":\(emoji.shortcode):\t\(emoji.url?.absoluteString ?? "(no url)")")
            }
        }
    }
}
