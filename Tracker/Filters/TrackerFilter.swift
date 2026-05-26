import Foundation

enum TrackerFilter: String, CaseIterable {
    case all
    case today
    case completed
    case incomplete

    var title: String {
        switch self {
        case .all:        return "Все трекеры"
        case .today:      return "Трекеры на сегодня"
        case .completed:  return "Завершённые"
        case .incomplete: return "Незавершённые"
        }
    }

    var isActive: Bool {
        self == .completed || self == .incomplete
    }
}
