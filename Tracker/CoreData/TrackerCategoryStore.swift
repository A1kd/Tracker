import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidUpdate()
}

final class TrackerCategoryStore: NSObject {

    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        super.init()
        _ = fetchedResultsController
    }

    func fetchAllTitles() -> [String] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return ((try? context.fetch(request)) ?? []).compactMap(\.title)
    }

    @discardableResult
    func ensureCategory(title: String) throws -> TrackerCategoryCoreData {
        if let existing = findCategory(by: title) {
            return existing
        }
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = title
        try context.save()
        return entity
    }

    func addCategory(title: String) throws {
        guard findCategory(by: title) == nil else { return }
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = title
        try context.save()
    }

    func renameCategory(oldTitle: String, newTitle: String) throws {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != oldTitle else { return }
        guard findCategory(by: trimmed) == nil else { return }
        guard let entity = findCategory(by: oldTitle) else { return }
        entity.title = trimmed
        try context.save()
    }

    func deleteCategory(title: String) throws {
        guard let entity = findCategory(by: title) else { return }
        context.delete(entity)
        try context.save()
    }

    private func findCategory(by title: String) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        return (try? context.fetch(request))?.first
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidUpdate()
    }
}
