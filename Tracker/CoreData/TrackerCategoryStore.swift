import CoreData

final class TrackerCategoryStore {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }

    func fetchAllTitles() throws -> [String] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return try context.fetch(request).compactMap(\.title)
    }

    @discardableResult
    func ensureCategory(title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        if let existing = try context.fetch(request).first {
            return existing
        }
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = title
        try context.save()
        return entity
    }
}
