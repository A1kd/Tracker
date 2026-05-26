import Foundation

final class AnalyticsService {

    static let shared = AnalyticsService()

    private init() {}

    func activate(apiKey: String) {
        AnalyticsBackend.shared.activate(apiKey: apiKey)
    }

    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        var params: [String: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        if let item {
            params["item"] = item.rawValue
        }
        #if DEBUG
        print("[Analytics] \(params)")
        #endif
        AnalyticsBackend.shared.report(event: event.rawValue, parameters: params)
    }
}
