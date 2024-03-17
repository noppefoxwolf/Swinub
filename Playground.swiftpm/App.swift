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
    var streaming = Streaming(
        endpoint: "wss://example.com/api/v1/streaming",
        stream: .userNotification,
        token: ""
    )!
    
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
