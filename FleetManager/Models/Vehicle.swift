import Foundation

enum VehicleType: String, CaseIterable, Codable {
    case car = "Automobile"
    case van = "Furgone"
    case truck = "Camion"
    case motorcycle = "Moto"
    case other = "Altro"

    var icon: String {
        switch self {
        case .car: return "car.fill"
        case .van: return "bus.fill"
        case .truck: return "shippingbox.fill"
        case .motorcycle: return "bicycle"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

struct Vehicle: Identifiable, Codable {
    var id: UUID
    var plate: String
    var brand: String
    var model: String
    var year: Int
    var type: VehicleType
    var fuelType: String
    var color: String
    var notes: String

    init(
        id: UUID = UUID(),
        plate: String,
        brand: String,
        model: String,
        year: Int,
        type: VehicleType = .car,
        fuelType: String = "",
        color: String = "",
        notes: String = ""
    ) {
        self.id = id
        self.plate = plate
        self.brand = brand
        self.model = model
        self.year = year
        self.type = type
        self.fuelType = fuelType
        self.color = color
        self.notes = notes
    }

    var displayName: String { "\(brand) \(model)" }
}
