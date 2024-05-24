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
    
    @State
    var statuses: [Swinub.Status] = []
    
    @MainActor
    init() {
        let request = ConnectV1Streaming(
            stream: .public,
            host: "mstdn.jp"
        )
        webSocketTask = try! SwinubDefaults.streamingSession.webSocketTask(for: request)
    }
    
    var body: some View {
        NavigationView(content: {
            List {
                ForEach(statuses) { status in
                    Text(status.id.rawValue)
                }
            }
            .navigationTitle("Swinub")
            .navigationBarTitleDisplayMode(.inline)
        })
        .task {
            do {
                for try await message in webSocketTask.messages {
                    switch message.event {
                    case .update(let status):
                        withAnimation {
                            statuses.insert(status, at: 0)
                        }
                    default:
                        break
                    }
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
