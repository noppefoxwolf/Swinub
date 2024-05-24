import SwiftUI
import Swinub
import SwinubStreaming

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State
    var webSocketTask: WebSocketTask<SwinubStreaming.Message>
    
    @MainActor
    init() {
        let authorization = Authorization(
            host: "mstdn.jp",
            accountID: Account.ID(rawValue: ""),
            oauthToken: ""
        )
        let request = ConnectV1Streaming(
            stream: .public,
            authorization: authorization
        )
        webSocketTask = try! SwinubDefaults.streamingSession.webSocketTask(for: request)
    }
    
    var body: some View {
        Text("Hello, World!")
            .task {
                do {
                    for try await message in webSocketTask.messages {
                        print(message)
                    }
                } catch {
                    print(error)
                }
            }
            .onAppear(perform: {
                webSocketTask.resume()
            })
    }
}
