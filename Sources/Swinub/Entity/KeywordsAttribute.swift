public struct KeywordsAttribute: Codable, Sendable {
    public init(keyword: String, wholeWord: Bool) {
        self.keyword = keyword
        self.wholeWord = wholeWord
    }

    public let keyword: String
    public let wholeWord: Bool
}
