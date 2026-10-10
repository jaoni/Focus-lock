import SwiftUI
import SwiftData

@main
struct Focus_LockApp: App {
    @State private var coordinator = SessionCoordinator()

    private let container: ModelContainer = {
        let schema = Schema([FocusSession.self])
        return try! ModelContainer(for: schema)
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(coordinator)
                .onAppear {
                    coordinator.setModelContext(container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
