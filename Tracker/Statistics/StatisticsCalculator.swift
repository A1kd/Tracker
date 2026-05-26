import Foundation

struct Statistics {
    let bestPeriod: Int
    let idealDays: Int
    let totalCompleted: Int
    let averagePerDay: Int

    var isEmpty: Bool {
        bestPeriod == 0 && idealDays == 0 && totalCompleted == 0 && averagePerDay == 0
    }
}

struct StatisticsCalculator {

    let trackerStore: TrackerStore
    let recordStore: TrackerRecordStore

    func compute() -> Statistics {
        let allRecords = (try? recordStore.fetchAll()) ?? []
        let allTrackers = trackerStore.fetchAllTrackers()
        let calendar = Calendar.iso8601Ru

        let totalCompleted = allRecords.count

        let recordsByDate = Dictionary(grouping: allRecords) {
            calendar.startOfDay(for: $0.date)
        }
        let uniqueDates = recordsByDate.keys.sorted()

        var bestPeriod = 0
        var currentStreak = 0
        var previousDate: Date?
        for date in uniqueDates {
            if let prev = previousDate {
                let dayDiff = calendar.dateComponents([.day], from: prev, to: date).day ?? 0
                currentStreak = dayDiff == 1 ? currentStreak + 1 : 1
            } else {
                currentStreak = 1
            }
            bestPeriod = max(bestPeriod, currentStreak)
            previousDate = date
        }

        var idealDays = 0
        for date in uniqueDates {
            let day = WeekDay.from(date: date)
            let scheduled = allTrackers.filter { !$0.schedule.isEmpty && $0.schedule.contains(day) }
            guard !scheduled.isEmpty else { continue }
            let completedIds = Set((recordsByDate[date] ?? []).map(\.trackerId))
            if scheduled.allSatisfy({ completedIds.contains($0.id) }) {
                idealDays += 1
            }
        }

        let average = uniqueDates.isEmpty
            ? 0
            : Int(round(Double(totalCompleted) / Double(uniqueDates.count)))

        return Statistics(
            bestPeriod: bestPeriod,
            idealDays: idealDays,
            totalCompleted: totalCompleted,
            averagePerDay: average
        )
    }
}
