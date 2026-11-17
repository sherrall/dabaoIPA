import Foundation

struct AppTarget: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var url: String
}

struct PauseAttempt: Codable, Identifiable {
    var id = UUID()
    let targetName: String
    let startedAt: Date
    let completedAt: Date
    let duration: TimeInterval
    let intention: String
}

@MainActor
final class PauseStore: ObservableObject {
    @Published private(set) var targets: [AppTarget]
    @Published private(set) var attempts: [PauseAttempt] = []
    @Published var intention = ""
    @Published private(set) var activeTarget: AppTarget?

    private let storageDirectory: URL
    private var startedAt: Date?

    init() {
        let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        storageDirectory = applicationSupport.appendingPathComponent("Helpe", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        } catch {
            NSLog("Helpe storage directory error: \(error.localizedDescription)")
        }

        targets = Self.load([AppTarget].self, from: storageDirectory.appendingPathComponent("targets.json"))
            ?? AppTarget.defaultTargets
        attempts = Self.load([PauseAttempt].self, from: storageDirectory.appendingPathComponent("attempts.json")) ?? []
    }

    var canStartPause: Bool {
        activeTarget == nil
    }

    func startPause(for target: AppTarget) {
        guard canStartPause else { return }
        activeTarget = target
        startedAt = Date()
    }

    func completePause() {
        guard let target = activeTarget, let startedAt else { return }
        let completedAt = Date()
        let attempt = PauseAttempt(
            targetName: target.name,
            startedAt: startedAt,
            completedAt: completedAt,
            duration: completedAt.timeIntervalSince(startedAt),
            intention: intention
        )
        attempts.insert(attempt, at: 0)
        resetActivePause()
        saveAttempts()
    }

    func cancelPause() {
        resetActivePause()
    }

    func addTarget(_ target: AppTarget) {
        targets.append(target)
        saveTargets()
    }

    func deleteTarget(at offsets: IndexSet) {
        targets.remove(atOffsets: offsets)
        saveTargets()
    }

    private func resetActivePause() {
        activeTarget = nil
        startedAt = nil
        intention = ""
    }

    private func saveTargets() {
        save(targets, to: storageDirectory.appendingPathComponent("targets.json"))
    }

    private func saveAttempts() {
        save(attempts, to: storageDirectory.appendingPathComponent("attempts.json"))
    }

    private func save(_ value: some Encodable, to url: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(value)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            NSLog("Helpe save error: \(error.localizedDescription)")
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: Data(contentsOf: url))
        } catch {
            NSLog("Helpe load error: \(error.localizedDescription)")
            return nil
        }
    }
}

extension AppTarget {
    static let defaultTargets = [
        AppTarget(name: "Safari", url: "x-web-search://"),
        AppTarget(name: "Mail", url: "message://")
    ]
}
