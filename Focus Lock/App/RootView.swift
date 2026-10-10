import SwiftUI

struct RootView: View {
    @Environment(SessionCoordinator.self) private var coordinator

    var body: some View {
        Group {
            if !coordinator.hasCompletedOnboarding {
                OnboardingView()
            } else {
                switch coordinator.phase {
                case .idle:
                    HomeView()
                case .active:
                    ActiveSessionView()
                case .complete(let summary):
                    SessionCompleteView(summary: summary)
                }
            }
        }
    }
}
