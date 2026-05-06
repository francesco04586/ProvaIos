import Foundation
import Combine

class FleetViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var deadlines: [Deadline] = []

    private let vehiclesKey = "fleet_vehicles"
    private let deadlinesKey = "fleet_deadlines"

    init() {
        loadData()
    }

    // MARK: - Vehicles

    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        saveVehicles()
    }

    func updateVehicle(_ vehicle: Vehicle) {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) else { return }
        vehicles[index] = vehicle
        saveVehicles()
    }

    func deleteVehicle(_ vehicle: Vehicle) {
        deadlines.removeAll { $0.vehicleId == vehicle.id }
        vehicles.removeAll { $0.id == vehicle.id }
        saveVehicles()
        saveDeadlines()
    }

    // MARK: - Deadlines

    func deadlines(for vehicle: Vehicle) -> [Deadline] {
        deadlines
            .filter { $0.vehicleId == vehicle.id }
            .sorted { $0.expirationDate < $1.expirationDate }
    }

    func addDeadline(_ deadline: Deadline) {
        deadlines.append(deadline)
        saveDeadlines()
        let vehicle = vehicle(for: deadline.vehicleId)
        NotificationManager.shared.scheduleNotification(for: deadline, vehicle: vehicle)
    }

    func updateDeadline(_ deadline: Deadline) {
        guard let index = deadlines.firstIndex(where: { $0.id == deadline.id }) else { return }
        deadlines[index] = deadline
        saveDeadlines()
        let vehicle = vehicle(for: deadline.vehicleId)
        NotificationManager.shared.updateNotification(for: deadline, vehicle: vehicle)
    }

    func deleteDeadline(_ deadline: Deadline) {
        deadlines.removeAll { $0.id == deadline.id }
        saveDeadlines()
        NotificationManager.shared.cancelNotification(for: deadline)
    }

    func deleteDeadlines(at offsets: IndexSet, for vehicle: Vehicle) {
        let vehicleDeadlines = deadlines(for: vehicle)
        for index in offsets {
            let d = vehicleDeadlines[index]
            deadlines.removeAll { $0.id == d.id }
            NotificationManager.shared.cancelNotification(for: d)
        }
        saveDeadlines()
    }

    func toggleCompleted(_ deadline: Deadline) {
        guard let index = deadlines.firstIndex(where: { $0.id == deadline.id }) else { return }
        deadlines[index].isCompleted.toggle()
        saveDeadlines()
    }

    // MARK: - Dashboard computed properties

    var expiredDeadlines: [Deadline] {
        deadlines.filter { $0.status == .expired }
    }

    var criticalDeadlines: [Deadline] {
        deadlines.filter { $0.status == .critical }
    }

    var upcomingDeadlines: [Deadline] {
        deadlines
            .filter { !$0.isCompleted && $0.daysRemaining >= 0 && $0.daysRemaining <= 90 }
            .sorted { $0.expirationDate < $1.expirationDate }
    }

    func allDeadlinesSorted() -> [Deadline] {
        deadlines.sorted { $0.expirationDate < $1.expirationDate }
    }

    func vehicle(for id: UUID) -> Vehicle? {
        vehicles.first { $0.id == id }
    }

    // MARK: - Persistence

    private func saveVehicles() {
        guard let data = try? JSONEncoder().encode(vehicles) else { return }
        UserDefaults.standard.set(data, forKey: vehiclesKey)
    }

    private func saveDeadlines() {
        guard let data = try? JSONEncoder().encode(deadlines) else { return }
        UserDefaults.standard.set(data, forKey: deadlinesKey)
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: vehiclesKey),
           let decoded = try? JSONDecoder().decode([Vehicle].self, from: data) {
            vehicles = decoded
        }
        if let data = UserDefaults.standard.data(forKey: deadlinesKey),
           let decoded = try? JSONDecoder().decode([Deadline].self, from: data) {
            deadlines = decoded
        }
    }
}
