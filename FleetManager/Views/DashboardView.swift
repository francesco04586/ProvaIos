import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: FleetViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Automezzi",
                            value: "\(viewModel.vehicles.count)",
                            icon: "car.fill",
                            color: .blue
                        )
                        StatCard(
                            title: "Scadute",
                            value: "\(viewModel.expiredDeadlines.count)",
                            icon: "exclamationmark.triangle.fill",
                            color: .red
                        )
                        StatCard(
                            title: "Critiche",
                            value: "\(viewModel.criticalDeadlines.count)",
                            icon: "clock.badge.exclamationmark.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)

                    // Expired alerts
                    if !viewModel.expiredDeadlines.isEmpty {
                        AlertSection(
                            title: "Scadenze Scadute",
                            deadlines: viewModel.expiredDeadlines,
                            color: .red
                        )
                    }

                    // Critical alerts
                    if !viewModel.criticalDeadlines.isEmpty {
                        AlertSection(
                            title: "Scadono entro 7 giorni",
                            deadlines: viewModel.criticalDeadlines,
                            color: .orange
                        )
                    }

                    // Upcoming 90 days
                    if !viewModel.upcomingDeadlines.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Prossime Scadenze (90 giorni)")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(viewModel.upcomingDeadlines.prefix(10)) { deadline in
                                DeadlineRowCard(deadline: deadline)
                                    .padding(.horizontal)
                            }
                        }
                    }

                    // Empty state
                    if viewModel.vehicles.isEmpty {
                        VStack(spacing: 14) {
                            Image(systemName: "car.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("Nessun automezzo registrato")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text("Vai alla scheda Automezzi per aggiungere\nil primo veicolo della flotta")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                .padding(.bottom, 30)
            }
            .navigationTitle("Fleet Manager")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Alert Section

struct AlertSection: View {
    let title: String
    let deadlines: [Deadline]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
            }
            .padding(.horizontal)

            ForEach(deadlines) { deadline in
                DeadlineRowCard(deadline: deadline)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(color.opacity(0.06))
        .cornerRadius(14)
        .padding(.horizontal)
    }
}

// MARK: - Deadline Row Card

struct DeadlineRowCard: View {
    let deadline: Deadline
    @EnvironmentObject var viewModel: FleetViewModel

    private var vehicle: Vehicle? { viewModel.vehicle(for: deadline.vehicleId) }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: deadline.type.icon)
                .foregroundColor(deadline.type.color)
                .font(.title3)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(deadline.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                if let v = vehicle {
                    Text("\(v.brand) \(v.model) · \(v.plate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(deadline.expirationDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                let days = deadline.daysRemaining
                if days < 0 {
                    Text("Scaduto")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                } else {
                    Text("\(days)g")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(deadline.status.color)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
