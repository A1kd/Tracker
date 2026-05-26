import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    let isPinned: Bool

    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay], isPinned: Bool = false) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isPinned = isPinned
    }
}
