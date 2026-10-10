import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

private let appGroup          = "group.focuslock.app"
private let sessionActiveKey  = "fl_sessionIsActive"
private let selectionDataKey  = "fl_activitySelectionData"

class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let managedStore = ManagedSettingsStore()

    private var defaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? .standard
    }

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        applyShield()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        clearShield()
        defaults.set(false, forKey: sessionActiveKey)
    }

    private func applyShield() {
        guard
            let data = defaults.data(forKey: selectionDataKey),
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
        managedStore.shield.applications = nil
        managedStore.shield.applicationCategories = nil
    }
}
