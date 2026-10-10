import SwiftUI

struct ActiveSessionView: View {
    @Environment(SessionCoordinator.self) private var coordinator
    @State private var showEndAlert = false
    @State private var tick = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.flBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Focus Lock")
                        .font(.instrumentSerif(size: 26))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                progressRing

                Spacer().frame(height: 40)

                Text("Stay locked in.")
                    .font(.instrumentSerif(size: 22, italic: true))
                    .foregroundColor(.white.opacity(0.7))

                Spacer().frame(height: 8)

                Text(coordinator.blockScreenMessage)
                    .font(.manrope(.regular, size: 14))
                    .foregroundColor(.flSubtext)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Button { showEndAlert = true } label: {
                    Text("End Early")
                        .font(.manrope(.medium, size: 16))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onReceive(timer) { _ in
            tick += 1
            if case .active = coordinator.phase, coordinator.timeRemaining <= 0 {
                coordinator.completeSession()
            }
        }
        .alert("End session early?", isPresented: $showEndAlert) {
            Button("End Session", role: .destructive) {
                Task { await coordinator.endSessionEarly() }
            }
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("Your progress won't count toward your streak.")
        }
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.flSurface, lineWidth: 10)
                .frame(width: 220, height: 220)

            Circle()
                .trim(from: 0, to: coordinator.progress)
                .stroke(
                    LinearGradient.flPrimary,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                Text(timeString(coordinator.timeRemaining))
                    .font(.instrumentSerif(size: 52, italic: true))
                    .foregroundColor(.white)
                    .monospacedDigit()
                Text("remaining")
                    .font(.manrope(.medium, size: 13))
                    .foregroundColor(.flSubtext)
                    .tracking(2)
                    .textCase(.uppercase)
            }
        }
    }

    private func timeString(_ interval: TimeInterval) -> String {
        let total = Int(max(0, interval))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}
