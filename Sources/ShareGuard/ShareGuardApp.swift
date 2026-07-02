import SwiftUI

@main
struct ShareGuardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 820, minHeight: 600)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 900, height: 700)
    }
}
