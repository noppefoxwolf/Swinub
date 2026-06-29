import ArgumentParser

@main
struct SwinubCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swinub-cli",
        abstract: "Utilities for working with Swinub.",
        subcommands: [Auth.self, Instance.self, Mentions.self, Post.self]
    )
}
