import SwiftUI

struct VehicleDetailView: View {
    let vehicle: Vehicle
    @EnvironmentObject var viewModel: FleetViewModel
    @State private var showingEditVehicle = false
    @State private var showingAddDeadline = false

    private var vehicleDeadlines: [Deadline] {
        viewModel.deadlines(for: vehicle)
    }

    var body: some View {
        List {
            // Vehicle info
            Section("Informazioni Veicolo") {
                InfoRow(label: "Targa", value: vehicle.plate, icon: "number")
                InfoRow(label: "Marca", value: vehicle.brand, icon: "building.2.fill")
                InfoRow(label: "Modello", value: vehicle.model, icon: "car.fill")
                InfoRow(label: "Anno", value: "\(vehicle.year)", icon: "calendar")
                InfoRow(label: "Tipo", value: vehicle.type.rawValue, icon: vehicle.type.icon)
                if !vehicle.fuelType.isEmpty {
                    InfoRow(label: "Carburante", value: vehicle.fuelType, icon: "fuelpump.fill")
                }
                if !vehicle.color.isEmpty {
                    InfoRow(label: "Colore", value: vehicle.color, icon: "paintpalette.fill")
                }
                if !vehicle.notes.isEmpty {
                    InfoRow(label: "Note", value: vehicle.notes, icon: "note.text")
                }
            }

            // Deadlines
            Section {
                if vehicleDeadlines.isEmpty {
                    Label("Nessuna scadenza registrata", systemImage: "checkmark.circle")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(vehicleDeadlines) { deadline in
                        DeadlineDetailRow(deadline: deadline)
                    }
                    .onDelete { offsets in
                        viewModel.deleteDeadlines(at: offsets, for: vehicle)
                    }
                }
            } header: {
                HStack {
                    Text("Scadenze")
                    Spacer()
                    Button(action: { showingAddDeadline = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(vehicle.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Modifica") { showingEditVehicle = true }
            }
        }
        .sheet(isPresented: $showingEditVehicle) {
            AddVehicleView(vehicle: vehicle)
        }
        .sheet(isPresented: $showingAddDeadline) {
            AddDeadlineView(vehicleId: vehicle.id)
        }
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 22)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Deadline Detail Row

struct DeadlineDetailRow: View {
    let deadline: Deadline
    @EnvironmentObject var viewModel: FleetViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: deadline.type.icon)
                .foregroundColor(deadline.type.color)
                .font(.title3)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text(deadline.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(deadline.isCompleted)

                HStack(spacing: 6) {
                    Text(deadline.expirationDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let cost = deadline.cost {
                        Text("· €\(cost, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if !deadline.notes.isEmpty {
                    Text(deadline.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                StatusBadge(status: deadline.status)
                Button(action: { viewModel.toggleCompleted(deadline) }) {
                    Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(deadline.isCompleted ? .green : .gray)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .opacity(deadline.isCompleted ? 0.55 : 1.0)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: DeadlineStatus

    var body: some View {
        Text(status.label)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(status.color.opacity(0.15))
            .foregroundColor(status.color)
            .cornerRadius(6)
    }
}
