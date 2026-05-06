import SwiftUI

enum DeadlineType: String, CaseIterable, Codable {
    case insurance = "Assicurazione"
    case tax = "Bollo"
    case inspection = "Revisione"
    case maintenance = "Manutenzione"
    case registration = "Immatricolazione"
    case other = "Altro"

    var icon: String {
        switch self {
        case .insurance: return "shield.fill"
        case .tax: return "doc.text.fill"
        case .inspection: return "wrench.and.screwdriver.fill"
        case .maintenance: return "gear.circle.fill"
        case .registration: return "doc.badge.plus"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .insurance: return .blue
        case .tax: return .green
        case .inspection: return .orange
        case .maintenance: return .purple
        case .registration: return .teal
        case .other: return .gray
        }
    }
}

enum DeadlineStatus: Equatable {
    case expired
    case critical   // <= 7 days
    case warning    // <= 30 days
    case ok

    var color: Color {
        switch self {
        case .expired: return .red
        case .critical: return .orange
        case .warning: return Color(red: 0.85, green: 0.65, blue: 0)
        case .ok: return .green
        }
    }

    var label: String {
        switch self {
        case .expired: return "Scaduto"
        case .critical: return "Critico"
        case .warning: return "In scadenza"
        case .ok: return "Regolare"
        }
    }
}

struct Deadline: Identifiable, Codable {
    var id: UUID
    var vehicleId: UUID
    var type: DeadlineType
    var expirationDate: Date
    var cost: Double?
    var notes: String
    var isCompleted: Bool
    var reminderDays: Int

    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        type: DeadlineType,
        expirationDate: Date,
        cost: Double? = nil,
        notes: String = "",
        isCompleted: Bool = false,
        reminderDays: Int = 30
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.type = type
        self.expirationDate = expirationDate
        self.cost = cost
        self.notes = notes
        self.isCompleted = isCompleted
        self.reminderDays = reminderDays
    }

    var status: DeadlineStatus {
        if isCompleted { return .ok }
        let days = daysRemaining
        if days < 0 { return .expired }
        if days <= 7 { return .critical }
        if days <= 30 { return .warning }
        return .ok
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()),
                                        to: Calendar.current.startOfDay(for: expirationDate)).day ?? 0
    }
}
