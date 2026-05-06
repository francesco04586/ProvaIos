import SwiftUI

struct AddDeadlineView: View {
    @EnvironmentObject var viewModel: FleetViewModel
    @Environment(\.dismiss) private var dismiss

    let vehicleId: UUID
    var deadline: Deadline? = nil

    @State private var type: DeadlineType = .insurance
    @State private var expirationDate = Date()
    @State private var hasCost = false
    @State private var cost: Double = 0.0
    @State private var notes = ""
    @State private var reminderDays = 30

    private let reminderOptions = [7, 14, 30, 60, 90]
    private var isEditing: Bool { deadline != nil }

    var body: some View {
        NavigationView {
            Form {
                // Tipo
                Section("Tipo Scadenza") {
                    Picker("Tipo", selection: $type) {
                        ForEach(DeadlineType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Data
                Section("Data di Scadenza") {
                    DatePicker(
                        "Data",
                        selection: $expirationDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: "it_IT"))
                }

                // Costo
                Section {
                    Toggle("Aggiungi importo", isOn: $hasCost.animation())
                    if hasCost {
                        HStack {
                            Text("€")
                                .foregroundColor(.secondary)
                            TextField("0,00", value: $cost, format: .number)
                                .keyboardType(.decimalPad)
                        }
                    }
                } header: {
                    Text("Importo")
                } footer: {
                    Text("Inserisci il costo del rinnovo/pagamento")
                        .font(.caption)
                }

                // Promemoria
                Section("Promemoria") {
                    Picker("Avviso anticipato", selection: $reminderDays) {
                        ForEach(reminderOptions, id: \.self) { days in
                            Text("\(days) giorni prima").tag(days)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Note
                Section("Note") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(isEditing ? "Modifica Scadenza" : "Nuova Scadenza")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") { save() }
                        .fontWeight(.bold)
                }
            }
            .onAppear { populateFields() }
        }
    }

    private func populateFields() {
        guard let d = deadline else { return }
        type = d.type
        expirationDate = d.expirationDate
        if let c = d.cost {
            hasCost = true
            cost = c
        }
        notes = d.notes
        reminderDays = d.reminderDays
    }

    private func save() {
        var d = Deadline(
            vehicleId: vehicleId,
            type: type,
            expirationDate: expirationDate,
            cost: hasCost ? cost : nil,
            notes: notes,
            reminderDays: reminderDays
        )
        if let existing = deadline {
            d.id = existing.id
            d.isCompleted = existing.isCompleted
            viewModel.updateDeadline(d)
        } else {
            viewModel.addDeadline(d)
        }
        dismiss()
    }
}
