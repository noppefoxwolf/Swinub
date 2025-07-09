import Foundation
import Swinub
import Testing

@Suite
struct GetNodeinfoTests {
    @Test(.enabled(if: !isRunningInCI()))
    func getNodeinfo() async throws {
        let request = GetWellKnownNodeinfo(host: "mstdn.jp")
        let (response, _) = try await URLSession.shared.response(for: request)
        #expect(response.links.count == 1)
        let link = response.links.max(by: { $0.rel < $1.rel })!
        #expect(link.rel == .v20)
        let request2 = GetNodeinfo(link: link)
        let (response2, _) = try await URLSession.shared.response(for: request2)
        #expect(response2.version == "2.0")
        #expect(response2.openRegistrations == true)
    }
}

func isRunningInCI() -> Bool {
    let environment = ProcessInfo.processInfo.environment

    let ciEnvironments = [
        "GITHUB_ACTIONS",
        "TRAVIS",
        "CIRCLECI",
        "GITLAB_CI",
        "JENKINS_HOME",
        "APPVEYOR",
    ]

    for ciEnv in ciEnvironments {
        if environment[ciEnv] != nil {
            return true
        }
    }

    return false
}
