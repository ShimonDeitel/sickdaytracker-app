import Foundation

struct SymptomEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var childName: String
    var date: Date
    var temperature: Double
    var symptom: String
    var medicineGiven: String

    init(id: UUID = UUID(), childName: String = "", date: Date = Date(), temperature: Double = 0, symptom: String = "", medicineGiven: String = "") {
        self.id = id
        self.childName = childName
        self.date = date
        self.temperature = temperature
        self.symptom = symptom
        self.medicineGiven = medicineGiven
    }
}
