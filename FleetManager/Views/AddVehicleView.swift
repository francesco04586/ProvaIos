import SwiftUI

struct AddVehicleView: View {
    @EnvironmentObject var viewModel: FleetViewModel
    @Environment(\.dismiss) private var dismiss

    var vehicle: Vehicle?

    @State private var plate = ""
    @State private var brand = ""
    @State private var model = ""
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var type: VehicleType = .car
    @State private var fuelType = ""
    @State private var color = ""
    @State private var notes = ""

    private var isEditing: Bool { vehicle != nil }
    private var currentYear: Int { Calendar.current.component(.year, from: Date()) }
    private var isSaveEnabled: Bool { !plate.trimmingCharacters(in: .whitespaces).isEmpty && !brand.isEmpty && !model.isEmpty }

    var body: some View {
        NavigationView {
            Form {
                Section("Dati Principali") {
                    HStack {
                        Text("Targa")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("AB123CD", text: $plate)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                    }
                    HStack {
                        Text("Marca")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("es. Fiat", text: $brand)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Modello")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("es. Ducato", text: $model)
                            .multilineTextAlignment(.trailing)
                    }
                    Stepper("Anno: \(year)", value: $year, in: 1950...currentYear + 1)
                }

                Section("Tipo Veicolo") {
                    Picker("Tipo", selection: $type) {
                        ForEach(VehicleType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Dettagli Aggiuntivi") {
                    HStack {
                        Text("Carburante")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("es. Diesel", text: $fuelType)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Colore")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("es. Bianco", text: $color)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Note") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(isEditing ? "Modifica Automezzo" : "Nuovo Automezzo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") { save() }
                        .fontWeight(.bold)
                        .disabled(!isSaveEnabled)
                }
            }
            .onAppear { populateFields() }
        }
    }

    private func populateFields() {
        guard let v = vehicle else { return }
        plate = v.plate
        brand = v.brand
        model = v.model
        year = v.year
        type = v.type
        fuelType = v.fuelType
        color = v.color
        notes = v.notes
    }

    private func save() {
        var v = Vehicle(
            plate: plate.uppercased().trimmingCharacters(in: .whitespaces),
            brand: brand,
            model: model,
            year: year,
            type: type,
            fuelType: fuelType,
            color: color,
            notes: notes
        )
        if let existing = vehicle {
            v.id = existing.id
            viewModel.updateVehicle(v)
        } else {
            viewModel.addVehicle(v)
        }
        dismiss()
    }
}
