import SwiftUI
import SwiftData
import FamilyControls
import DeviceActivity
import ManagedSettings

@MainActor
@Observable
final class SessionCoordinator {

    var phase: SessionPhase = .idle
    var isAuthorized: Bool = false
    var selectedAppCount: Int = 0

    var strictMode: Bool = false {
        didSet { store.strictMode = strictMode }
    }
    var allowCallsAndTexts: Bool = true {
        didSet { store.allowCallsAndTexts = allowCallsAndTexts }
    }
    var blockScreenMessage: String = "Whatever it was, it can wait. You've got this." {
        didSet { store.blockScreenMessage = blockScreenMessage }
    }
    var defaultSessionLength: Int = 50 {
        didSet { store.defaultSessionLength = defaultSessionLength }
    }
    var hasCompletedOnboarding: Bool = false {
        didSet { store.hasCompletedOnboarding = hasCompletedOnboarding }
    }

    private let store = SharedStore.shared
    private let managedStore = ManagedSettingsStore()
    private let activityCenter = DeviceActivityCenter()
    private let activityName = DeviceActivityName("focuslock.session")
    private var modelContext: ModelContext?

    init() {
        strictMode              = store.strictMode
        allowCallsAndTexts      = store.allowCallsAndTexts
        blockScreenMessage      = store.blockScreenMessage
        defaultSessionLength    = store.defaultSessionLength
        hasCompletedOnboarding  = store.hasCompletedOnboarding
        restoreSessionIfActive()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        } catch {
            isAuthorized = false
        }
    }

    func checkAuthorizationStatus() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    func startSession(minutes: Int) async {
        let start = Date()
        let end   = start.addingTimeInterval(TimeInterval(minutes * 60))
        store.sessionIsActive  = true
        store.sessionStartDate = start
        store.sessionEndDate   = end
        store.distractionCount = 0
        phase = .active(endDate: end)
        applyShield()
        scheduleActivity(start: start, end: end)
    }

    func endSessionEarly() async {
        guard case .active = phase else { return }
        let elapsed = elapsedMinutes()
        recordSession(actualMinutes: elapsed, completed: false)
        cancelActivity()
        clearShield()
        store.clearSession()
        phase = .idle
    }

    func completeSession() {
        guard case .active(let endDate) = phase,
              let start = store.sessionStartDate else { return }
        let planned    = Int(endDate.timeIntervalSince(start) / 60)
        let distracted = store.distractionCount
        let streak     = computeStreak()
        recordSession(actualMinutes: planned, completed: true)
        cancelActivity()
        clearShield()
        store.clearSession()
        phase = .complete(summary: SessionSummary(
            minutesFocused: planned,
            dayStreak: streak,
            distractionsResisted: distracted
        ))
    }

    func dismissComplete() {
        phase = .idle
    }

    var timeRemaining: TimeInterval {
        guard case .active(let endDate) = phase else { return 0 }
        return max(0, endDate.timeIntervalSinceNow)
    }

    var progress: Double {
        guard case .active(let endDate) = phase,
              let start = store.sessionStartDate else { return 0 }
        let total   = endDate.timeIntervalSince(start)
        guard total > 0 else { return 0 }
        let elapsed = Date().timeIntervalSince(start)
        return min(1, max(0, elapsed / total))
    }

    var plannedMinutes: Int {
        guard case .active(let endDate) = phase,
              let start = store.sessionStartDate else { return defaultSessionLength }
        return Int(endDate.timeIntervalSince(start) / 60)
    }

    private func restoreSessionIfActive() {
        guard store.sessionIsActive, let endDate = store.sessionEndDate else { return }
        if endDate > Date() {
            phase = .active(endDate: endDate)
        } else {
            if let start = store.sessionStartDate {
                recordSession(
                    actualMinutes: Int(endDate.timeIntervalSince(start) / 60),
                    completed: true
                )
            }
            store.clearSession()
        }
    }

    private func elapsedMinutes() -> Int {
        guard let start = store.sessionStartDate else { return 0 }
        return Int(Date().timeIntervalSince(start) / 60)
    }

    private func recordSession(actualMinutes: Int, completed: Bool) {
        guard let context = modelContext,
              let start   = store.sessionStartDate,
              let end     = store.sessionEndDate else { return }
        let planned = Int(end.timeIntervalSince(start) / 60)
        context.insert(FocusSession(
            startDate:            start,
            plannedMinutes:       planned,
            actualMinutes:        actualMinutes,
            completed:            completed,
            distractionsResisted: store.distractionCount
        ))
        try? context.save()
    }

    private func computeStreak() -> Int {
        guard let context = modelContext else { return 0 }
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.completed },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        guard let sessions = try? context.fetch(descriptor) else { return 0 }
        let cal = Calendar.current
        var streak = 0
        var checkDay = cal.startOfDay(for: Date())
        while true {
            let hasSession = sessions.contains {
                cal.isDate($0.startDate, inSameDayAs: checkDay)
            }
            if hasSession {
                streak += 1
                checkDay = cal.date(byAdding: .day, value: -1, to: checkDay) ?? checkDay
            } else {
                break
            }
        }
        return streak
    }

    private func scheduleActivity(start: Date, end: Date) {
        let cal = Calendar.current
        let schedule = DeviceActivitySchedule(
            intervalStart: cal.dateComponents([.hour, .minute, .second], from: start),
            intervalEnd:   cal.dateComponents([.hour, .minute, .second], from: end),
            repeats: false
        )
        do {
            try activityCenter.startMonitoring(activityName, during: schedule)
        } catch {
            activityCenter.stopMonitoring([activityName])
            try? activityCenter.startMonitoring(activityName, during: schedule)
        }
    }

    private func cancelActivity() {
        activityCenter.stopMonitoring([activityName])
    }

    private func applyShield() {
        guard
            let data      = store.activitySelectionData,
            let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return }

        if !selection.applicationTokens.isEmpty {
            managedStore.shield.applications = selection.applicationTokens
        }
        if !selection.categoryTokens.isEmpty {
            managedStore.shield.applicationCategories = .specific(selection.categoryTokens)
        }
    }

    private func clearShield() {
        managedStore.shield.applications        = nil
        managedStore.shield.applicationCategories = nil
    }
}
