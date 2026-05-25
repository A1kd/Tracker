import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
}

final class TrackerStore: NSObject {

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
            sectionNameKeyPath: "category.title",
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
        entity.category = category
        try context.save()
        return entity
    }

    func categories() -> [TrackerCategory] {
        let sections = fetchedResultsController.sections ?? []
        return sections.map { section in
            let trackers = (section.objects as? [TrackerCoreData] ?? []).compactMap(toStruct)
            return TrackerCategory(title: section.name, trackers: trackers)
        }
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
            schedule: deserializeSchedule(entity.schedule ?? "")
        )
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}
