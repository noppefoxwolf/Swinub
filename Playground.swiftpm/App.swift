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
    var streaming = StreamingSession(
        endpoint: URL(string: "wss://example.com")!,
        stream: .userNotification,
        token: ""
    )
    
    var body: some View {
        Text("Hello, World!")
            .task {
                do {
                    for try await message in streaming.message.values {
                        print(message)
                    }
                } catch {}
            }
            .onAppear(perform: {
                streaming.connect()
            })
    }
}
