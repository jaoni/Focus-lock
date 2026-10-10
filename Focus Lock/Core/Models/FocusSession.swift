import Foundation
import SwiftData

@Model
final class FocusSession {
    var startDate: Date
    var plannedMinutes: Int
    var actualMinutes: Int
    var completed: Bool
    var distractionsResisted: Int

    init(startDate: Date,
         plannedMinutes: Int,
         actualMinutes: Int,
         completed: Bool,
         distractionsResisted: Int) {
        self.startDate = startDate
        self.plannedMinutes = plannedMinutes
        self.actualMinutes = actualMinutes
        self.completed = completed
        self.distractionsResisted = distractionsResisted
    }
}
