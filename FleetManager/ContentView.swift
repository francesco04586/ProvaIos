import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FleetViewModel

    var alertCount: Int {
        viewModel.expiredDeadlines.count + viewModel.criticalDeadlines.count
    }

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            VehicleListView()
                .tabItem {
                    Label("Automezzi", systemImage: "car.fill")
                }
                .badge(viewModel.vehicles.count > 0 ? viewModel.vehicles.count : 0)

            DeadlineListView()
                .tabItem {
                    Label("Scadenze", systemImage: "calendar.badge.exclamationmark")
                }
                .badge(alertCount > 0 ? alertCount : 0)
        }
    }
}
