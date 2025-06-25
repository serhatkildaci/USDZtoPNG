import SwiftUI

@main
struct USDZtoPNGApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 700)
                .preferredColorScheme(.light) // Ensure consistent appearance
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                // Remove default new window command since we're a single-window app
            }
        }
    }
} 