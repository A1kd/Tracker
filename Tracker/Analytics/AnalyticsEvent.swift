import Foundation

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
    case statistics = "Statistics"
    case filters = "Filters"
    case categories = "Categories"
    case schedule = "Schedule"
    case trackerForm = "TrackerForm"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}
