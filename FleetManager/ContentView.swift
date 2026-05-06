import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FleetViewModel

    private var urgentDeadlinesCount: Int {
        viewModel.expiredDeadlines.count + viewModel.criticalDeadlines.count
    }

    private var vehiclesWithAlertsCount: Int {
        viewModel.vehicles.filter { vehicle in
            viewModel.deadlines(for: vehicle).contains {
                $0.status == .expired || $0.status == .critical
            }
        }.count
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
                .badge(vehiclesWithAlertsCount > 0 ? vehiclesWithAlertsCount : 0)

            DeadlineListView()
                .tabItem {
                    Label("Scadenze", systemImage: "calendar.badge.exclamationmark")
                }
                .badge(urgentDeadlinesCount > 0 ? urgentDeadlinesCount : 0)
        }
    }
}
