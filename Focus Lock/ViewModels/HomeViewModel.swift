import Foundation

@Observable
@MainActor
final class HomeViewModel {
    var selectedMinutes: Int

    init(defaultMinutes: Int = 50) {
        self.selectedMinutes = defaultMinutes
    }

    var captionText: String {
        "This closes the door for \(selectedMinutes) minutes."
    }

    var durationLabel: String {
        "\(selectedMinutes)"
    }

    var presets: [(label: String, minutes: Int)] {
        [(label: "25", minutes: 25),
         (label: "50", minutes: 50),
         (label: "90", minutes: 90),
         (label: "⋯", minutes: 0)]
    }

    var isCustomSelected: Bool {
        ![25, 50, 90].contains(selectedMinutes)
    }

    func startSession(coordinator: SessionCoordinator) {
        Task { await coordinator.startSession(minutes: selectedMinutes) }
    }
}
