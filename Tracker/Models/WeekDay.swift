import Foundation

enum WeekDay: Int, CaseIterable, Codable, Hashable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var fullName: String {
        switch self {
        case .monday:    return "Понедельник"
        case .tuesday:   return "Вторник"
        case .wednesday: return "Среда"
        case .thursday:  return "Четверг"
        case .friday:    return "Пятница"
        case .saturday:  return "Суббота"
        case .sunday:    return "Воскресенье"
        }
    }

    var shortName: String {
        switch self {
        case .monday:    return "Пн"
        case .tuesday:   return "Вт"
        case .wednesday: return "Ср"
        case .thursday:  return "Чт"
        case .friday:    return "Пт"
        case .saturday:  return "Сб"
        case .sunday:    return "Вс"
        }
    }

    static func from(date: Date, calendar: Calendar = .iso8601Ru) -> WeekDay {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .saturday
        }
    }
}

extension Calendar {
    static let iso8601Ru: Calendar = {
        var c = Calendar(identifier: .iso8601)
        c.locale = Locale(identifier: "ru_RU")
        c.firstWeekday = 2
        return c
    }()
}
