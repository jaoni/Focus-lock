import Foundation

enum SessionPhase {
    case idle
    case active(endDate: Date)
    case complete(summary: SessionSummary)
}
