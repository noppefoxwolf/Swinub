import SwiftUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink("Login") {
                        LoginExampleView()
                    }
                    NavigationLink("Streaming") {
                        StreamingExampleView()
                    }
                }
            }
        }
    }
}
