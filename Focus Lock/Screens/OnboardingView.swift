import SwiftUI
import FamilyControls

struct OnboardingView: View {
    @Environment(SessionCoordinator.self) private var coordinator
    @State private var isRequesting = false

    var body: some View {
        ZStack {
            Color.flBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(LinearGradient.flPrimary)
                        .frame(width: 80, height: 80)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }

                Spacer().frame(height: 32)

                Text("Focus Lock")
                    .font(.instrumentSerif(size: 40, italic: true))
                    .foregroundColor(.white)

                Spacer().frame(height: 12)

                Text("Block the apps that steal your time.\nLock in and do the work.")
                    .font(.manrope(.regular, size: 16))
                    .foregroundColor(.flSubtext)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)

                Spacer().frame(height: 48)

                VStack(spacing: 20) {
                    OnboardingStep(icon: "hand.raised.fill",   text: "Grant Screen Time permission to block apps")
                    OnboardingStep(icon: "timer",              text: "Set a focus duration and pick apps to block")
                    OnboardingStep(icon: "checkmark.seal.fill", text: "Lock in — stay focused until the timer ends")
                }
                .padding(.horizontal, 32)

                Spacer()

                Button {
                    Task {
                        isRequesting = true
                        await coordinator.requestAuthorization()
                        isRequesting = false
                        if coordinator.isAuthorized {
                            coordinator.hasCompletedOnboarding = true
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isRequesting {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        }
                        Text(isRequesting ? "Requesting…" : "Get Started")
                            .font(.manrope(.bold, size: 18))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(LinearGradient.flPrimary)
                    .cornerRadius(16)
                }
                .disabled(isRequesting)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

private struct OnboardingStep: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.flPrimary)
                .frame(width: 24)
            Text(text)
                .font(.manrope(.regular, size: 14))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
        }
    }
}
