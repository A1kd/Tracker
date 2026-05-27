import Foundation
import AppMetricaCore

final class AnalyticsBackend {

    static let shared = AnalyticsBackend()

    private var activated = false

    private init() {}

    func activate(apiKey: String) {
        guard !activated else { return }
        guard let config = AppMetricaConfiguration(apiKey: apiKey) else {
            assertionFailure("Invalid AppMetrica apiKey")
            return
        }
        AppMetrica.activate(with: config)
        activated = true
    }

    func report(event: String, parameters: [String: Any]) {
        guard activated else { return }
        AppMetrica.reportEvent(name: event, parameters: parameters)
    }
}
