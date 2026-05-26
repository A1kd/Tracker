import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
}

final class TrackerStore: NSObject {

    static let pinnedCategoryTitle = "Закреплённые"

    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore
    weak var delegate: TrackerStoreDelegate?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true),
        ]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            assertionFailure("FRC fetch failed: \(error)")
        }
        return frc
    }()

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        self.categoryStore = TrackerCategoryStore(context: context)
        super.init()
        _ = fetchedResultsController
    }

    @discardableResult
    func add(_ tracker: Tracker, to categoryTitle: String) throws -> TrackerCoreData {
        let category = try categoryStore.ensureCategory(title: categoryTitle)
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.name = tracker.name
        entity.colorHex = tracker.color.toHexString()
        entity.emoji = tracker.emoji
        entity.schedule = serializeSchedule(tracker.schedule)
        entity.isPinned = tracker.isPinned
        entity.category = category
        try context.save()
        return entity
    }

    func togglePinned(trackerId: UUID) throws {
        guard let entity = try fetchTracker(id: trackerId) else { return }
        entity.isPinned.toggle()
        try context.save()
    }

    func delete(trackerId: UUID) throws {
        guard let entity = try fetchTracker(id: trackerId) else { return }
        context.delete(entity)
        try context.save()
    }

    func categories() -> [TrackerCategory] {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let entities = (try? context.fetch(request)) ?? []

        let pinnedTrackers = entities.filter { $0.isPinned }.compactMap(toStruct)
        let pinnedCategory = pinnedTrackers.isEmpty
            ? nil
            : TrackerCategory(title: Self.pinnedCategoryTitle, trackers: pinnedTrackers)

        var grouped: [String: [Tracker]] = [:]
        for entity in entities where !entity.isPinned {
            guard let title = entity.category?.title, let tracker = toStruct(entity) else { continue }
            grouped[title, default: []].append(tracker)
        }
        let regular = grouped.sorted { $0.key < $1.key }
            .map { TrackerCategory(title: $0.key, trackers: $0.value) }

        return ([pinnedCategory].compactMap { $0 }) + regular
    }

    private func fetchTracker(id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func serializeSchedule(_ schedule: [WeekDay]) -> String {
        schedule.map { String($0.rawValue) }.joined(separator: ",")
    }

    private func deserializeSchedule(_ raw: String) -> [WeekDay] {
        raw.split(separator: ",")
            .compactMap { Int($0) }
            .compactMap { WeekDay(rawValue: $0) }
    }

    private func toStruct(_ entity: TrackerCoreData) -> Tracker? {
        guard let id = entity.id,
              let name = entity.name,
              let colorHex = entity.colorHex,
              let emoji = entity.emoji else {
            return nil
        }
        return Tracker(
            id: id,
            name: name,
            color: UIColor(hex: colorHex),
            emoji: emoji,
            schedule: deserializeSchedule(entity.schedule ?? ""),
            isPinned: entity.isPinned
        )
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}
