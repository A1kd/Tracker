import CoreData

final class TrackerRecordStore {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }

    func add(_ record: TrackerRecord) throws {
        let entity = TrackerRecordCoreData(context: context)
        entity.trackerId = record.trackerId
        entity.date = record.date
        if let tracker = try fetchTracker(id: record.trackerId) {
            entity.tracker = tracker
        }
        try context.save()
    }

    func remove(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            record.date as CVarArg
        )
        let matches = try context.fetch(request)
        for match in matches {
            context.delete(match)
        }
        try context.save()
    }

    func hasRecord(trackerId: UUID, on date: Date) throws -> Bool {
        let calendar = Calendar.iso8601Ru
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return false }
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            start as CVarArg,
            end as CVarArg
        )
        request.fetchLimit = 1
        return try context.count(for: request) > 0
    }

    func count(forTrackerId trackerId: UUID) throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        return try context.count(for: request)
    }

    private func fetchTracker(id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
