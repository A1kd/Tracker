import Foundation

enum L10n {
    static var trackersTab: String   { NSLocalizedString("Trackers.tab", comment: "") }
    static var statisticsTab: String { NSLocalizedString("Statistics.tab", comment: "") }
    static var filtersButton: String { NSLocalizedString("Filters.button", comment: "") }
    static var searchPlaceholder: String { NSLocalizedString("Search.placeholder", comment: "") }
    static var cancel: String { NSLocalizedString("Cancel", comment: "") }

    static func days(_ count: Int) -> String {
        String(format: NSLocalizedString("Days.count", comment: ""), count)
    }
}
