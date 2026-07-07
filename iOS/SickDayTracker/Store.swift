import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [SymptomEntry] = []
    @Published var isPro: Bool = false

    static let freeLimit = 200

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("sickdaytracker_items.json")
        load()
    }

    var isAtFreeLimit: Bool {
        !isPro && items.count >= Store.freeLimit
    }

    func add(_ item: SymptomEntry) -> Bool {
        guard !isAtFreeLimit else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: SymptomEntry) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: SymptomEntry) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([SymptomEntry].self, from: data) else {
            items = [
        SymptomEntry(childName: "Sample Childname 1", date: Calendar.current.date(byAdding: .day, value: -0, to: Date()) ?? Date(), temperature: 5.0, symptom: "Sample Symptom 1", medicineGiven: "Sample Medicinegiven 1"),
        SymptomEntry(childName: "Sample Childname 2", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), temperature: 10.0, symptom: "Sample Symptom 2", medicineGiven: "Sample Medicinegiven 2"),
        SymptomEntry(childName: "Sample Childname 3", date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), temperature: 15.0, symptom: "Sample Symptom 3", medicineGiven: "Sample Medicinegiven 3")
            ]
            save()
            return
        }
        items = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
