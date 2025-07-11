import Foundation
import Testing

@testable import Swinub

@Suite("WebAuthenticationSessionDataFactoryTests")
struct WebAuthenticationSessionDataFactoryTests {
    @Test func makeURL() async throws {
        let factory = WebAuthenticationSessionDataFactory(
            host: "",
            clientId: "",
            redirectUri: "",
            scopes: []
        )
        let url = try factory.makeURL(
            locale: Locale(
                languageCode: .japanese,
                languageRegion: .japan
            )
        )
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let lang = try #require(components?.queryItems?.first(where: { $0.name == "lang" })?.value)
        #expect(lang == "ja_JP")
    }
}
