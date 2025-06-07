import SwiftUI
import Swinub
import AuthenticationServices

struct LoginExampleView: View {
    
    @Environment(\.webAuthenticationSession)
    var webAuthenticationSession
    
    var body: some View {
        Button {
            Task {
                let host = "mastodon.social"
                let app = try await {
                    let request = PostV1Apps(
                        host: host,
                        clientName: "test",
                        redirectURI: "callback://"
                    )
                    return try await SwinubDefaults.session.response(for: request).response
                }()
                let dataFactory = WebAuthenticationSessionDataFactory(
                    host: host,
                    clientId: app.clientId,
                    redirectUri: app.redirectUri
                )
                let url = try dataFactory.makeURL(locale: Locale(identifier: "en-US"))
                let callbackURLScheme = try dataFactory.makeCallbackURLScheme()
                let urlWithToken = try await webAuthenticationSession.authenticate(
                    using: url,
                    callbackURLScheme: callbackURLScheme,
                    preferredBrowserSession: .ephemeral
                )
                print(urlWithToken)
            }
        } label: {
            Text("Login")
        }

    }
}
