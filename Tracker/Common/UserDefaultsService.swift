import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()

    private let defaults = UserDefaults.standard

    private init() {}

    private enum Key {
        static let onboardingCompleted = "onboardingCompleted"
        static let currentFilter = "currentFilter"
    }

    var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: Key.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Key.onboardingCompleted) }
    }

    var currentFilter: TrackerFilter {
        get {
            guard let raw = defaults.string(forKey: Key.currentFilter),
                  let value = TrackerFilter(rawValue: raw) else { return .all }
            return value
        }
        set { defaults.set(newValue.rawValue, forKey: Key.currentFilter) }
    }
}
