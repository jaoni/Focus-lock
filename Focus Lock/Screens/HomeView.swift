import SwiftUI
import FamilyControls

struct HomeView: View {
    @Environment(SessionCoordinator.self) private var coordinator
    @State private var viewModel: HomeViewModel
    @State private var activitySelection = FamilyActivitySelection()
    @State private var showAppPicker = false
    @State private var showSettings = false
    @State private var showCustomDuration = false

    init() {
        _viewModel = State(wrappedValue: HomeViewModel(defaultMinutes: SharedStore.shared.defaultSessionLength))
    }

    var body: some View {
        ZStack {
            Color.flBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Focus Lock")
                        .font(.instrumentSerif(size: 26))
                        .foregroundColor(.white)
                    Spacer()
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                VStack(spacing: 6) {
                    Text(viewModel.durationLabel)
                        .font(.instrumentSerif(size: 100, italic: true))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: viewModel.selectedMinutes)
                    Text("minutes")
                        .font(.manrope(.medium, size: 13))
                        .foregroundColor(.flSubtext)
                        .tracking(3)
                        .textCase(.uppercase)
                }

                Spacer().frame(height: 36)

                HStack(spacing: 10) {
                    ForEach(viewModel.presets, id: \.label) { preset in
                        Button {
                            if preset.minutes == 0 {
                                showCustomDuration = true
                            } else {
                                viewModel.selectedMinutes = preset.minutes
                            }
                        } label: {
                            Text(preset.label)
                                .font(.manrope(.semiBold, size: 15))
                                .foregroundColor(isActive(preset) ? .white : .white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background {
                                    if isActive(preset) {
                                        LinearGradient.flPrimary
                                    } else {
                                        Color.white.opacity(0.07)
                                    }
                                }
                                .cornerRadius(12)
                        }
                        .animation(.easeInOut(duration: 0.15), value: viewModel.selectedMinutes)
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 12)

                Text(viewModel.captionText)
                    .font(.manrope(.regular, size: 13))
                    .foregroundColor(.flSubtext)

                Spacer()

                Button { showAppPicker = true } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.flPrimary)
                        Text(coordinator.selectedAppCount > 0
                             ? "\(coordinator.selectedAppCount) app\(coordinator.selectedAppCount == 1 ? "" : "s") selected"
                             : "Choose apps to block")
                            .font(.manrope(.medium, size: 15))
                            .foregroundColor(coordinator.selectedAppCount > 0 ? .white : .white.opacity(0.6))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(16)
                    .background(Color.flSurface)
                    .cornerRadius(14)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 12)

                Button { viewModel.startSession(coordinator: coordinator) } label: {
                    Text("Lock In")
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
        .onAppear { syncSelection() }
        .sheet(isPresented: $showAppPicker) {
            FamilyActivityPickerSheet(selection: $activitySelection)
                .onDisappear { saveSelection() }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showCustomDuration) {
            CustomDurationSheet(selectedMinutes: $viewModel.selectedMinutes)
        }
    }

    private func isActive(_ preset: (label: String, minutes: Int)) -> Bool {
        preset.minutes == 0 ? viewModel.isCustomSelected : viewModel.selectedMinutes == preset.minutes
    }

    private func syncSelection() {
        if let data = SharedStore.shared.activitySelectionData,
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            activitySelection = selection
            coordinator.selectedAppCount = selection.applicationTokens.count + selection.categoryTokens.count
        }
    }

    private func saveSelection() {
        if let data = try? JSONEncoder().encode(activitySelection) {
            SharedStore.shared.activitySelectionData = data
            coordinator.selectedAppCount = activitySelection.applicationTokens.count + activitySelection.categoryTokens.count
        }
    }
}

private struct FamilyActivityPickerSheet: View {
    @Binding var selection: FamilyActivitySelection
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            FamilyActivityPicker(selection: $selection)
                .navigationTitle("Block Apps")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

private struct CustomDurationSheet: View {
    @Binding var selectedMinutes: Int
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Int

    init(selectedMinutes: Binding<Int>) {
        _selectedMinutes = selectedMinutes
        _draft = State(wrappedValue: selectedMinutes.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.flBackground.ignoresSafeArea()
                Picker("Duration", selection: $draft) {
                    ForEach([5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 75, 90, 105, 120], id: \.self) { min in
                        Text("\(min) min").tag(min)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("Custom Duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedMinutes = draft
                        dismiss()
                    }
                    .foregroundColor(.flPrimary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
