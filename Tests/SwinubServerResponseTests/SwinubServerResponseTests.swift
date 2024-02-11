import Swinub
import XCTest

class SwinubServerResponseTests: XCTestCase {
    func testConfiguration() async throws {
        // Popular mastodon hosts.
        let hosts = [
            "fedibird.com",
            "mstdn.jp",
            "mastodon.social",
            "pawoo.net",
            "pokemon.mastportal.info",
            "mstdn.maud.io",
            "kmy.blue",
            "unnerv.jp",
            "fosstodon.org",
            "mstdn.kemono-friends.info",
            // "akamdon.com", /* 401 */
            "songbird.cloud",
            "k.my-sky.blue",
            "kblue.10rino.net",
            "ff.ryumu.dev",
            "otadon.com",
            "mastodon-japan.net",
            "mozilla.social",
            "social.vivaldi.net",
        ]
        
        try await withThrowingTaskGroup(of: GetV1Instance.Response.self) { taskGroup in
            for host in hosts {
                taskGroup.addTask {
                    let request = GetV1Instance(host: host)
                    let response = try await SwinubDefaults.session.response(for: request)
                    return response.response
                }
            }
            
            try await taskGroup.waitForAll()
        }
    }
}

