import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: Store
    @EnvironmentObject private var purchaseManager: PurchaseManager

    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: SymptomEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(describing: item.childName))
                                    .font(Theme.headlineFont)
                                    .foregroundStyle(Theme.accent)
                                Text(item.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .accessibilityIdentifier("row_\(item.id.uuidString)")
                    }
                    .onDelete(perform: store.delete)
                    .listRowBackground(Theme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Sick Day Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("button_settings")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.isAtFreeLimit {
                            showingPaywall = true
                        } else {
                            showingAdd = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("button_add")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                EntryFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

enum FormMode: Equatable {
    case add
    case edit(SymptomEntry)
}

struct EntryFormView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss

    let mode: FormMode
    @State private var draft: SymptomEntry

    init(mode: FormMode) {
        self.mode = mode
        switch mode {
        case .add:
            _draft = State(initialValue: SymptomEntry())
        case .edit(let item):
            _draft = State(initialValue: item)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("ChildName", text: $draft.childName)
                    .accessibilityIdentifier("field_childName")
                DatePicker("Date", selection: $draft.date, displayedComponents: .date)
                    .accessibilityIdentifier("field_date")
                TextField("Temperature", value: $draft.temperature, format: .number)
                    .keyboardType(.decimalPad)
                    .accessibilityIdentifier("field_temperature")
                TextField("Symptom", text: $draft.symptom)
                    .accessibilityIdentifier("field_symptom")
                TextField("MedicineGiven", text: $draft.medicineGiven)
                    .accessibilityIdentifier("field_medicineGiven")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(mode == .add ? "Add" : "Edit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("button_cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        switch mode {
                        case .add:
                            _ = store.add(draft)
                        case .edit:
                            store.update(draft)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("button_save")
                }
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
