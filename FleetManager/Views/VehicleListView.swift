import SwiftUI

struct VehicleListView: View {
    @EnvironmentObject var viewModel: FleetViewModel
    @State private var showingAddVehicle = false
    @State private var searchText = ""

    private var filteredVehicles: [Vehicle] {
        guard !searchText.isEmpty else { return viewModel.vehicles }
        return viewModel.vehicles.filter {
            $0.plate.localizedCaseInsensitiveContains(searchText) ||
            $0.brand.localizedCaseInsensitiveContains(searchText) ||
            $0.model.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.vehicles.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filteredVehicles) { vehicle in
                            NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                                VehicleRowView(vehicle: vehicle)
                            }
                        }
                        .onDelete { offsets in
                            let toDelete = offsets.map { filteredVehicles[$0] }
                            toDelete.forEach { viewModel.deleteVehicle($0) }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $searchText, prompt: "Cerca targa, marca o modello")
                }
            }
            .navigationTitle("Automezzi")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddVehicle = true }) {
                        Image(systemName: "plus")
                    }
                }
                if !viewModel.vehicles.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddVehicle) {
                AddVehicleView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "car.fill")
                .font(.system(size: 72))
                .foregroundColor(.gray.opacity(0.35))
            Text("Nessun automezzo")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Aggiungi il primo veicolo della flotta")
                .foregroundColor(.secondary)
            Button(action: { showingAddVehicle = true }) {
                Label("Aggiungi Automezzo", systemImage: "plus.circle.fill")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - Vehicle Row

struct VehicleRowView: View {
    let vehicle: Vehicle
    @EnvironmentObject var viewModel: FleetViewModel

    private var urgentCount: Int {
        viewModel.deadlines(for: vehicle).filter {
            $0.status == .expired || $0.status == .critical
        }.count
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: vehicle.type.icon)
                    .font(.title3)
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(vehicle.displayName)
                    .font(.headline)
                Text(vehicle.plate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(vehicle.year) · \(vehicle.type.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if urgentCount > 0 {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 22, height: 22)
                    Text("\(urgentCount)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
