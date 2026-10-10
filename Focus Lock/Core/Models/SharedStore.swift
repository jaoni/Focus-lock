import Foundation

final class SharedStore {
    static let shared = SharedStore()

    private let defaults: UserDefaults

    private init() {
        defaults = UserDefaults(suiteName: "group.focuslock.app") ?? .standard
    }

    var sessionIsActive: Bool {
        get { defaults.bool(forKey: "fl_sessionIsActive") }
        set { defaults.set(newValue, forKey: "fl_sessionIsActive") }
    }

    var sessionStartDate: Date? {
        get { defaults.object(forKey: "fl_sessionStartDate") as? Date }
        set { defaults.set(newValue, forKey: "fl_sessionStartDate") }
    }

    var sessionEndDate: Date? {
        get { defaults.object(forKey: "fl_sessionEndDate") as? Date }
        set { defaults.set(newValue, forKey: "fl_sessionEndDate") }
    }

    var distractionCount: Int {
        get { defaults.integer(forKey: "fl_distractionCount") }
        set { defaults.set(newValue, forKey: "fl_distractionCount") }
    }

    var strictMode: Bool {
        get { defaults.bool(forKey: "fl_strictMode") }
        set { defaults.set(newValue, forKey: "fl_strictMode") }
    }

    var allowCallsAndTexts: Bool {
        get {
            guard defaults.object(forKey: "fl_allowCallsAndTexts") != nil else { return true }
            return defaults.bool(forKey: "fl_allowCallsAndTexts")
        }
        set { defaults.set(newValue, forKey: "fl_allowCallsAndTexts") }
    }

    var blockScreenMessage: String {
        get { defaults.string(forKey: "fl_blockScreenMessage") ?? "Whatever it was, it can wait. You've got this." }
        set { defaults.set(newValue, forKey: "fl_blockScreenMessage") }
    }

    var defaultSessionLength: Int {
        get {
            let val = defaults.integer(forKey: "fl_defaultSessionLength")
            return val == 0 ? 50 : val
        }
        set { defaults.set(newValue, forKey: "fl_defaultSessionLength") }
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: "fl_hasCompletedOnboarding") }
        set { defaults.set(newValue, forKey: "fl_hasCompletedOnboarding") }
    }

    var activitySelectionData: Data? {
        get { defaults.data(forKey: "fl_activitySelectionData") }
        set { defaults.set(newValue, forKey: "fl_activitySelectionData") }
    }

    func clearSession() {
        sessionIsActive = false
        sessionStartDate = nil
        sessionEndDate = nil
        distractionCount = 0
    }
}
