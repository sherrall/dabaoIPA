import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: PauseStore
    @State private var isBreathing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                if let target = store.activeTarget {
                    PauseFlowView(isBreathing: $isBreathing, target: target)
                } else {
                    idleView
                }
            }
            .padding()
            .navigationTitle("Pause")
        }
    }

    private var idleView: some View {
        VStack(spacing: 24) {
            Image(systemName: "wind")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(.tint)

            Text("Choose an app to pause.")
                .font(.title3)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                ForEach(store.targets) { target in
                    Button {
                        store.startPause(for: target)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "app")
                                .font(.title2)
                            Text(target.name)
                                .font(.footnote.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct PauseFlowView: View {
    @EnvironmentObject private var store: PauseStore
    @Binding var isBreathing: Bool
    let target: AppTarget

    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .fill(Color.accentColor.opacity(0.22))
                .frame(width: 180, height: 180)
                .scaleEffect(isBreathing ? 1.22 : 0.92)
                .animation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true), value: isBreathing)
                .onAppear { isBreathing = true }

            Text("Open \(target.name)?")
                .font(.title2.weight(.semibold))

            TextField(
                "What is your intention?",
                text: Binding(get: { store.intention }, set: { store.intention = $0 })
            )
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 12)

            Button {
                store.completePause()
                openTarget()
            } label: {
                Text("Continue to \(target.name)")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)

            Button("Cancel") {
                isBreathing = false
                store.cancelPause()
            }
        }
    }

    private func openTarget() {
        guard let url = URL(string: target.url) else { return }
        UIApplication.shared.open(url)
    }
}

struct TargetsView: View {
    @EnvironmentObject private var store: PauseStore
    @State private var name = ""
    @State private var url = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Add App Shortcut") {
                    TextField("Name", text: $name)
                    TextField("URL scheme", text: $url)
                    Button("Add") {
                        add()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || url.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                Section("Shortcuts") {
                    ForEach(store.targets) { target in
                        Label(target.name, systemImage: "app")
                    }
                    .onDelete(perform: store.deleteTarget)
                }
            }
            .navigationTitle("Targets")
        }
    }

    private func add() {
        let target = AppTarget(
            name: name.trimmingCharacters(in: .whitespaces),
            url: url.trimmingCharacters(in: .whitespaces)
        )
        store.addTarget(target)
        name = ""
        url = ""
    }
}

struct HistoryView: View {
    @EnvironmentObject private var store: PauseStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.attempts) { attempt in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(attempt.targetName)
                            .font(.headline)
                        Text(attempt.intention.isEmpty ? "No intention recorded" : attempt.intention)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(attempt.completedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .navigationTitle("History")
            .overlay {
                if store.attempts.isEmpty {
                    Text("No attempts yet.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
