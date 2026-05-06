import SwiftUI

@main
struct FleetManagerApp: App {
    @StateObject private var viewModel = FleetViewModel()

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
