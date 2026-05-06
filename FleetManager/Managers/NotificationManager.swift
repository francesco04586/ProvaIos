import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func scheduleNotification(for deadline: Deadline, vehicle: Vehicle?) {
        guard !deadline.isCompleted else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(deadline.type.rawValue) in scadenza"
        let plate = vehicle.map { " (\($0.plate))" } ?? ""
        let name = vehicle.map { "\($0.brand) \($0.model)" } ?? "Veicolo"
        content.body = "\(name)\(plate): scade tra \(deadline.reminderDays) giorni"
        content.sound = .default

        guard let reminderDate = Calendar.current.date(
            byAdding: .day, value: -deadline.reminderDays, to: deadline.expirationDate
        ), reminderDate > Date() else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: deadline.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func updateNotification(for deadline: Deadline, vehicle: Vehicle?) {
        cancelNotification(for: deadline)
        scheduleNotification(for: deadline, vehicle: vehicle)
    }

    func cancelNotification(for deadline: Deadline) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [deadline.id.uuidString])
    }
}
