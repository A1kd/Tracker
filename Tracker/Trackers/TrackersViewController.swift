import UIKit

final class TrackersViewController: UIViewController {

    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()

    var currentDate: Date = Calendar.iso8601Ru.startOfDay(for: Date())

    private var searchText: String = ""

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar = .iso8601Ru
        picker.date = currentDate
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return picker
    }()

    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = L10n.searchPlaceholder
        sb.searchBarStyle = .minimal
        sb.searchTextField.font = .systemFont(ofSize: 17)
        sb.delegate = self
        sb.setValue(L10n.cancel, forKey: "cancelButtonText")
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseID)
        cv.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.reuseID
        )
        cv.keyboardDismissMode = .onDrag
        return cv
    }()

    private lazy var filtersButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(L10n.filtersButton, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        b.backgroundColor = .ypBlue
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(filtersTapped), for: .touchUpInside)
        applyFiltersButtonStyle(b)
        return b
    }()

    private func applyFiltersButtonStyle(_ button: UIButton) {
        let isActive = UserDefaultsService.shared.currentFilter.isActive
        button.setTitleColor(isActive ? .ypRed : .white, for: .normal)
    }

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(resource: .emptyTrackers),
            title: "Что будем отслеживать?"
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        trackerStore.delegate = self
        setupNavBar()
        setupLayout()
        reload()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: .open, screen: .main)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.report(event: .close, screen: .main)
    }

    private func setupNavBar() {
        navigationItem.title = L10n.trackersTab
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let plusButton = UIBarButtonItem(
            image: SystemImages.plusBold,
            style: .plain,
            target: self,
            action: #selector(plusTapped)
        )
        plusButton.tintColor = .ypBlackDay
        navigationItem.leftBarButtonItem = plusButton

        let dateContainer = UIView()
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        dateContainer.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: dateContainer.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            dateContainer.widthAnchor.constraint(equalToConstant: 140),
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateContainer)
    }

    private func setupLayout() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        view.addSubview(filtersButton)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),

            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        collectionView.contentInset.bottom = 82
        collectionView.verticalScrollIndicatorInsets.bottom = 82
    }

    // MARK: - Data

    private var visibleCategories: [TrackerCategory] {
        let day = WeekDay.from(date: currentDate)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filter = UserDefaultsService.shared.currentFilter

        return trackerStore.categories().compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let scheduleMatch: Bool
                if tracker.schedule.isEmpty {
                    scheduleMatch = true
                } else {
                    scheduleMatch = tracker.schedule.contains(day)
                }
                let searchMatch = query.isEmpty || tracker.name.lowercased().contains(query)
                guard scheduleMatch && searchMatch else { return false }

                switch filter {
                case .all, .today:
                    return true
                case .completed:
                    return (try? recordStore.hasRecord(trackerId: tracker.id, on: currentDate)) ?? false
                case .incomplete:
                    return !((try? recordStore.hasRecord(trackerId: tracker.id, on: currentDate)) ?? false)
                }
            }
            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
    }

    private var hasTrackersForCurrentDay: Bool {
        let day = WeekDay.from(date: currentDate)
        return trackerStore.categories().contains { category in
            category.trackers.contains { tracker in
                tracker.schedule.isEmpty || tracker.schedule.contains(day)
            }
        }
    }

    private func reload() {
        let categories = visibleCategories
        let isEmpty = categories.flatMap(\.trackers).isEmpty
        let hasSearchQuery = !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if isEmpty {
            if hasSearchQuery {
                emptyStateView.configure(
                    image: UIImage(resource: .emptySearch),
                    title: "Ничего не найдено"
                )
            } else {
                emptyStateView.configure(
                    image: UIImage(resource: .emptyTrackers),
                    title: "Что будем отслеживать?"
                )
            }
        }
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
        filtersButton.isHidden = !hasTrackersForCurrentDay
    }

    private func isTrackerCompletedToday(_ tracker: Tracker) -> Bool {
        (try? recordStore.hasRecord(trackerId: tracker.id, on: currentDate)) ?? false
    }

    private func completedCount(for tracker: Tracker) -> Int {
        (try? recordStore.count(forTrackerId: tracker.id)) ?? 0
    }

    // MARK: - Actions

    @objc private func plusTapped() {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .addTrack)
        let typeVC = TrackerTypeSelectionViewController()
        typeVC.onSelect = { [weak self] type in
            self?.dismiss(animated: true) {
                self?.presentCreate(for: type)
            }
        }
        let nav = UINavigationController(rootViewController: typeVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func presentCreate(for type: TrackerType) {
        let form = TrackerFormViewController(type: type)
        form.onCreate = { [weak self] tracker, categoryTitle in
            self?.addTracker(tracker, to: categoryTitle)
        }
        let nav = UINavigationController(rootViewController: form)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        do {
            try trackerStore.add(tracker, to: categoryTitle)
            shiftDateIfNeeded(for: tracker)
            // reload triggered via TrackerStoreDelegate
        } catch {
            assertionFailure("Failed to add tracker: \(error)")
        }
    }

    private func shiftDateIfNeeded(for tracker: Tracker) {
        guard !tracker.schedule.isEmpty else { return }
        let currentDay = WeekDay.from(date: currentDate)
        guard !tracker.schedule.contains(currentDay) else { return }

        let calendar = Calendar.iso8601Ru
        for offset in 1...7 {
            guard let nextDate = calendar.date(byAdding: .day, value: offset, to: currentDate) else { continue }
            let nextDay = WeekDay.from(date: nextDate)
            if tracker.schedule.contains(nextDay) {
                currentDate = calendar.startOfDay(for: nextDate)
                datePicker.date = currentDate
                return
            }
        }
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = Calendar.iso8601Ru.startOfDay(for: sender.date)
        reload()
    }

    @objc private func filtersTapped() {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .filter)
        let vc = FilterListViewController(currentFilter: UserDefaultsService.shared.currentFilter)
        vc.onSelect = { [weak self] filter in
            self?.applyFilter(filter)
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func applyFilter(_ filter: TrackerFilter) {
        UserDefaultsService.shared.currentFilter = filter
        if filter == .today {
            currentDate = Calendar.iso8601Ru.startOfDay(for: Date())
            datePicker.date = currentDate
        }
        applyFiltersButtonStyle(filtersButton)
        reload()
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreDidUpdate() {
        reload()
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        reload()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchText = ""
        reload()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionView

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TrackerCellDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseID,
            for: indexPath
        ) as! TrackerCell
        cell.configure(
            with: tracker,
            isCompleted: isTrackerCompletedToday(tracker),
            count: completedCount(for: tracker)
        )
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSectionHeaderView.reuseID,
            for: indexPath
        ) as! TrackerSectionHeaderView
        header.titleLabel.text = visibleCategories[indexPath.section].title
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - 16 * 2 - 9
        let itemWidth = floor(availableWidth / 2)
        return CGSize(width: itemWidth, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 46)
    }

    // MARK: Context menu

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let pinTitle = tracker.isPinned ? "Открепить" : "Закрепить"
            let pin = UIAction(title: pinTitle) { _ in
                try? self?.trackerStore.togglePinned(trackerId: tracker.id)
            }
            let edit = UIAction(title: "Редактировать") { _ in
                AnalyticsService.shared.report(event: .click, screen: .main, item: .edit)
                self?.presentEdit(for: tracker)
            }
            let delete = UIAction(title: "Удалить", attributes: .destructive) { _ in
                AnalyticsService.shared.report(event: .click, screen: .main, item: .delete)
                self?.confirmDelete(tracker: tracker)
            }
            return UIMenu(children: [pin, edit, delete])
        }
    }

    private func currentCategory(for tracker: Tracker) -> String {
        for category in trackerStore.categories() {
            if category.title == TrackerStore.pinnedCategoryTitle { continue }
            if category.trackers.contains(where: { $0.id == tracker.id }) {
                return category.title
            }
        }
        return "Важное"
    }

    private func presentEdit(for tracker: Tracker) {
        let category = currentCategory(for: tracker)
        let completed = (try? recordStore.count(forTrackerId: tracker.id)) ?? 0
        let form = TrackerFormViewController(mode: .edit(
            tracker: tracker,
            categoryTitle: category,
            completedDays: completed
        ))
        form.onSave = { [weak self] updated, newCategory in
            try? self?.trackerStore.update(updated, categoryTitle: newCategory)
        }
        let nav = UINavigationController(rootViewController: form)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func confirmDelete(tracker: Tracker) {
        let sheet = UIAlertController(
            title: "Уверены, что хотите удалить трекер?",
            message: nil,
            preferredStyle: .actionSheet
        )
        sheet.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            try? self?.trackerStore.delete(trackerId: tracker.id)
        })
        sheet.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(sheet, animated: true)
    }

    // MARK: TrackerCellDelegate

    func trackerCellDidToggleCompletion(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]

        let today = Calendar.iso8601Ru.startOfDay(for: Date())
        if currentDate > today { return }

        AnalyticsService.shared.report(event: .click, screen: .main, item: .track)

        do {
            let record = TrackerRecord(trackerId: tracker.id, date: currentDate)
            if try recordStore.hasRecord(trackerId: tracker.id, on: currentDate) {
                try recordStore.remove(record)
            } else {
                try recordStore.add(record)
            }
            collectionView.reloadItems(at: [indexPath])
        } catch {
            assertionFailure("Toggle completion failed: \(error)")
        }
    }
}
