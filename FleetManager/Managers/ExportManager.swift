import UIKit

struct ExportManager {

    static func generateDeadlineReport(vehicles: [Vehicle], deadlines: [Deadline]) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { ctx in
            ctx.beginPage()

            let left: CGFloat = 40
            let right: CGFloat = 555.2
            let width = right - left
            var y: CGFloat = 40

            // ── Header ──────────────────────────────────────────────
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.systemBlue
            ]
            "Fleet Manager – Report Scadenze".draw(at: CGPoint(x: left, y: y), withAttributes: titleAttrs)
            y += 32

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "it_IT")

            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            "Generato il \(dateFormatter.string(from: Date()))".draw(
                at: CGPoint(x: left, y: y), withAttributes: subAttrs
            )
            y += 20

            // Blue separator
            let sep = UIBezierPath()
            sep.move(to: CGPoint(x: left, y: y))
            sep.addLine(to: CGPoint(x: right, y: y))
            UIColor.systemBlue.setStroke()
            sep.lineWidth = 1.5
            sep.stroke()
            y += 16

            // ── Summary ──────────────────────────────────────────────
            let sectionAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.darkGray
            ]

            "Riepilogo".draw(at: CGPoint(x: left, y: y), withAttributes: sectionAttrs)
            y += 16

            let expired  = deadlines.filter { $0.status == .expired  }.count
            let critical = deadlines.filter { $0.status == .critical }.count
            let warning  = deadlines.filter { $0.status == .warning  }.count

            let summaryText =
                "Automezzi: \(vehicles.count)   |   " +
                "Scadenze totali: \(deadlines.count)   |   " +
                "Scadute: \(expired)   |   " +
                "Critiche (≤7g): \(critical)   |   " +
                "In scadenza (≤30g): \(warning)"
            summaryText.draw(at: CGPoint(x: left, y: y), withAttributes: bodyAttrs)
            y += 28

            // ── Table header ─────────────────────────────────────────
            let cols: [(String, CGFloat, CGFloat)] = [
                ("Veicolo",        left + 2,   130),
                ("Targa",          left + 136,  68),
                ("Tipo",           left + 208, 100),
                ("Scadenza",       left + 312,  80),
                ("Giorni",         left + 396,  54),
                ("Stato",          left + 454,  99)
            ]

            let hdrAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 9),
                .foregroundColor: UIColor.white
            ]
            UIColor.systemBlue.setFill()
            CGRect(x: left, y: y, width: width, height: 18).fill()
            for (title, x, _) in cols {
                title.draw(at: CGPoint(x: x, y: y + 4), withAttributes: hdrAttrs)
            }
            y += 18

            // ── Rows ─────────────────────────────────────────────────
            let sortedDeadlines = deadlines.sorted { $0.expirationDate < $1.expirationDate }
            let shortDate = DateFormatter()
            shortDate.dateStyle = .short
            shortDate.locale = Locale(identifier: "it_IT")

            for (idx, deadline) in sortedDeadlines.enumerated() {
                if y > pageRect.height - 60 {
                    ctx.beginPage()
                    y = 40
                }

                // Alternating row background
                if idx % 2 == 0 {
                    UIColor(white: 0.96, alpha: 1).setFill()
                    CGRect(x: left, y: y, width: width, height: 18).fill()
                }

                let vehicle = vehicles.first { $0.id == deadline.vehicleId }
                let days = deadline.daysRemaining

                let rowAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9),
                    .foregroundColor: UIColor.black
                ]
                let statusColor: UIColor
                switch deadline.status {
                case .expired:  statusColor = .systemRed
                case .critical: statusColor = .systemOrange
                case .warning:  statusColor = UIColor(red: 0.75, green: 0.55, blue: 0, alpha: 1)
                case .ok:       statusColor = .systemGreen
                }
                let statusAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 9),
                    .foregroundColor: statusColor
                ]

                let vehicleName = vehicle.map { "\($0.brand) \($0.model)" } ?? "—"
                let plate       = vehicle?.plate ?? "—"
                let daysStr     = days < 0 ? "\(abs(days))g fa" : "\(days)g"

                let values: [(String, [NSAttributedString.Key: Any])] = [
                    (vehicleName,                   rowAttrs),
                    (plate,                          rowAttrs),
                    (deadline.type.rawValue,         rowAttrs),
                    (shortDate.string(from: deadline.expirationDate), rowAttrs),
                    (daysStr,                        rowAttrs),
                    (deadline.status.label,          statusAttrs)
                ]
                for (i, (text, attrs)) in values.enumerated() {
                    text.draw(at: CGPoint(x: cols[i].1, y: y + 4), withAttributes: attrs)
                }

                // Row divider
                let div = UIBezierPath()
                div.move(to: CGPoint(x: left, y: y + 18))
                div.addLine(to: CGPoint(x: right, y: y + 18))
                UIColor.lightGray.withAlphaComponent(0.4).setStroke()
                div.lineWidth = 0.5
                div.stroke()
                y += 18
            }

            // ── Footer ───────────────────────────────────────────────
            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 8),
                .foregroundColor: UIColor.lightGray
            ]
            "Fleet Manager App – Report generato automaticamente".draw(
                at: CGPoint(x: left, y: pageRect.height - 28),
                withAttributes: footerAttrs
            )
        }
    }
}
