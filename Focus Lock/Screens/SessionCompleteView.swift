import SwiftUI

struct SessionCompleteView: View {
    @Environment(SessionCoordinator.self) private var coordinator
    let summary: SessionSummary

    var body: some View {
        ZStack {
            Color.flBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(LinearGradient.flPrimary)
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer().frame(height: 24)

                Text("Session Complete")
                    .font(.instrumentSerif(size: 34, italic: true))
                    .foregroundColor(.white)

                Spacer().frame(height: 8)

                Text("You locked in and delivered.")
                    .font(.manrope(.regular, size: 15))
                    .foregroundColor(.flSubtext)

                Spacer().frame(height: 48)

                HStack(spacing: 0) {
                    StatCard(value: "\(summary.minutesFocused)", label: "Minutes\nFocused")
                    Rectangle()
                        .fill(Color.flBackground)
                        .frame(width: 1, height: 50)
                    StatCard(value: "\(summary.dayStreak)", label: "Day\nStreak")
                    Rectangle()
                        .fill(Color.flBackground)
                        .frame(width: 1, height: 50)
                    StatCard(value: "\(summary.distractionsResisted)", label: "Distractions\nResisted")
                }
                .background(Color.flSurface)
                .cornerRadius(16)
                .padding(.horizontal, 24)

                Spacer()

                Button { coordinator.dismissComplete() } label: {
                    Text("Done")
                        .font(.manrope(.bold, size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(LinearGradient.flPrimary)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

private struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.instrumentSerif(size: 36, italic: true))
                .foregroundColor(.white)
            Text(label)
                .font(.manrope(.regular, size: 12))
                .foregroundColor(.flSubtext)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}
