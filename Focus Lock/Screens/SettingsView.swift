import SwiftUI

struct SettingsView: View {
    @Environment(SessionCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.flBackground.ignoresSafeArea()

                List {
                    Section {
                        ToggleRow(
                            icon: "lock.shield.fill",
                            title: "Strict Mode",
                            subtitle: "Can't end sessions early once started",
                            isOn: Binding(
                                get: { coordinator.strictMode },
                                set: { coordinator.strictMode = $0 }
                            )
                        )
                        ToggleRow(
                            icon: "phone.fill",
                            title: "Allow Calls & Texts",
                            subtitle: "Phone and Messages stay unblocked",
                            isOn: Binding(
                                get: { coordinator.allowCallsAndTexts },
                                set: { coordinator.allowCallsAndTexts = $0 }
                            )
                        )
                    } header: {
                        sectionHeader("Session")
                    }
                    .listRowBackground(Color.flSurface)

                    Section {
                        HStack {
                            Text("Default Duration")
                                .font(.manrope(.medium, size: 15))
                                .foregroundColor(.white)
                            Spacer()
                            Stepper(
                                "\(coordinator.defaultSessionLength) min",
                                value: Binding(
                                    get: { coordinator.defaultSessionLength },
                                    set: { coordinator.defaultSessionLength = $0 }
                                ),
                                in: 5...240,
                                step: 5
                            )
                            .font(.manrope(.regular, size: 14))
                            .foregroundColor(.flSubtext)
                            .labelsHidden()
                        }
                    } header: {
                        sectionHeader("Defaults")
                    }
                    .listRowBackground(Color.flSurface)

                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Block Screen Message")
                                .font(.manrope(.medium, size: 15))
                                .foregroundColor(.white)
                            TextField(
                                "Message shown on blocked apps",
                                text: Binding(
                                    get: { coordinator.blockScreenMessage },
                                    set: { coordinator.blockScreenMessage = $0 }
                                ),
                                axis: .vertical
                            )
                            .font(.manrope(.regular, size: 14))
                            .foregroundColor(.flSubtext)
                            .lineLimit(3)
                        }
                        .padding(.vertical, 4)
                    } header: {
                        sectionHeader("Block Screen")
                    }
                    .listRowBackground(Color.flSurface)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.manrope(.semiBold, size: 16))
                        .foregroundColor(.flPrimary)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.manrope(.semiBold, size: 12))
            .foregroundColor(.flSubtext)
            .tracking(1.5)
            .textCase(.uppercase)
    }
}

private struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.flPrimary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manrope(.medium, size: 15))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.manrope(.regular, size: 12))
                    .foregroundColor(.flSubtext)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(.flPrimary)
        }
    }
}
