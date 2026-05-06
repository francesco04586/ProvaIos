import SwiftUI

struct DeadlineListView: View {
    @EnvironmentObject var viewModel: FleetViewModel
    @State private var selectedType: DeadlineType? = nil
    @State private var showCompleted = false
    @State private var showExportSheet = false
    @State private var pdfData: Data? = nil

    private var filteredDeadlines: [Deadline] {
        var result = viewModel.allDeadlinesSorted()
        if !showCompleted {
            result = result.filter { !$0.isCompleted }
        }
        if let filter = selectedType {
            result = result.filter { $0.type == filter }
        }
        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "Tutte",
                            icon: "list.bullet",
                            isSelected: selectedType == nil,
                            action: { selectedType = nil }
                        )
                        ForEach(DeadlineType.allCases, id: \.self) { type in
                            FilterChip(
                                title: type.rawValue,
                                icon: type.icon,
                                isSelected: selectedType == type,
                                action: {
                                    selectedType = (selectedType == type) ? nil : type
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color(.systemGroupedBackground))

                List {
                    if filteredDeadlines.isEmpty {
                        Label("Nessuna scadenza trovata", systemImage: "checkmark.circle")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(filteredDeadlines) { deadline in
                            AllDeadlineRow(deadline: deadline)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Scadenze")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showCompleted.toggle()
                    } label: {
                        Image(systemName: showCompleted ? "eye.slash" : "eye")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        pdfData = ExportManager.generateDeadlineReport(
                            vehicles: viewModel.vehicles,
                            deadlines: viewModel.allDeadlinesSorted()
                        )
                        showExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(viewModel.deadlines.isEmpty)
                }
            }
            .sheet(isPresented: $showExportSheet) {
                if let data = pdfData {
                    ShareSheet(items: [data])
                }
            }
        }
    }
}

// MARK: - Share Sheet (UIKit bridge)

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? Color.blue : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.07), radius: 2)
        }
    }
}

// MARK: - All Deadline Row

struct AllDeadlineRow: View {
    let deadline: Deadline
    @EnvironmentObject var viewModel: FleetViewModel

    private var vehicle: Vehicle? { viewModel.vehicle(for: deadline.vehicleId) }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(deadline.status.color)
                .frame(width: 4, height: 50)

            Image(systemName: deadline.type.icon)
                .foregroundColor(deadline.type.color)
                .font(.title3)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text(deadline.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(deadline.isCompleted)
                if let v = vehicle {
                    Text("\(v.brand) \(v.model) · \(v.plate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let cost = deadline.cost {
                    Text("€\(cost, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(deadline.expirationDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)

                let days = deadline.daysRemaining
                if !deadline.isCompleted {
                    if days < 0 {
                        Text("\(abs(days))g fa")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    } else {
                        Text("\(days) giorni")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(deadline.status.color)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(deadline.isCompleted ? 0.5 : 1.0)
        .swipeActions(edge: .leading) {
            Button {
                viewModel.toggleCompleted(deadline)
            } label: {
                Label(
                    deadline.isCompleted ? "Riapri" : "Completa",
                    systemImage: deadline.isCompleted ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(.green)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteDeadline(deadline)
            } label: {
                Label("Elimina", systemImage: "trash")
            }
        }
    }
}
