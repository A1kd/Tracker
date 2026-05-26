import Foundation

/// Placeholder backend until AppMetrica SDK is wired in via SPM.
/// When AppMetrica is added, replace the body with `AppMetrica.activate(with:)`
/// and `AppMetrica.reportEvent(name:parameters:)` calls.
final class AnalyticsBackend {

    static let shared = AnalyticsBackend()

    private var activated = false

    private init() {}

    func activate(apiKey: String) {
        activated = true
        #if DEBUG
        print("[Analytics] activated with key prefix \(apiKey.prefix(4))…")
        #endif
    }

    func report(event: String, parameters: [String: Any]) {
        guard activated else { return }
        // No-op until SDK is hooked up.
    }
}
