import Foundation

struct CategoryListItem {
    let title: String
    let isSelected: Bool
}

final class CategoryListViewModel {

    var onItemsChange: (([CategoryListItem]) -> Void)?
    var onSelect: ((String) -> Void)?

    private let store: TrackerCategoryStore
    private(set) var items: [CategoryListItem] = []
    private(set) var selectedTitle: String?

    init(store: TrackerCategoryStore = TrackerCategoryStore(),
         selectedTitle: String?) {
        self.store = store
        self.selectedTitle = selectedTitle
        store.delegate = self
        reload()
    }

    var numberOfRows: Int { items.count }

    func item(at index: Int) -> CategoryListItem {
        items[index]
    }

    func selectRow(at index: Int) {
        let title = items[index].title
        selectedTitle = title
        reload()
        onSelect?(title)
    }

    func addCategory(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        try? store.addCategory(title: trimmed)
        reload()
    }

    func reloadFromStore() {
        reload()
    }

    private func reload() {
        let titles = store.fetchAllTitles()
        items = titles.map { CategoryListItem(title: $0, isSelected: $0 == selectedTitle) }
        onItemsChange?(items)
    }
}

extension CategoryListViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidUpdate() {
        reload()
    }
}
