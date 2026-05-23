import UIKit

final class TrackersViewController: UIViewController {

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
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

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Поиск"
        sc.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        return sc
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

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(named: "EmptyTrackers"),
            title: "Что будем отслеживать?"
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavBar()
        setupLayout()
        reload()
    }

    private func setupNavBar() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let plusButton = UIBarButtonItem(
            image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
            style: .plain,
            target: self,
            action: #selector(plusTapped)
        )
        plusButton.tintColor = .ypBlackDay
        navigationItem.leftBarButtonItem = plusButton

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupLayout() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Data

    private var visibleCategories: [TrackerCategory] {
        let day = WeekDay.from(date: currentDate)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let scheduleMatch: Bool
                if tracker.schedule.isEmpty {
                    scheduleMatch = true
                } else {
                    scheduleMatch = tracker.schedule.contains(day)
                }
                let searchMatch = query.isEmpty || tracker.name.lowercased().contains(query)
                return scheduleMatch && searchMatch
            }
            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
    }

    private func reload() {
        let categories = visibleCategories
        let isEmpty = categories.flatMap(\.trackers).isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }

    private func isTrackerCompletedToday(_ tracker: Tracker) -> Bool {
        completedTrackers.contains { record in
            record.trackerId == tracker.id &&
            Calendar.iso8601Ru.isDate(record.date, inSameDayAs: currentDate)
        }
    }

    private func completedCount(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.trackerId == tracker.id }.count
    }

    // MARK: - Actions

    @objc private func plusTapped() {
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
        let vc: UIViewController
        switch type {
        case .habit:
            let habit = NewHabitViewController()
            habit.onCreate = { [weak self] tracker in
                self?.addTracker(tracker)
            }
            vc = habit
        case .irregular:
            let irregular = NewIrregularEventViewController()
            irregular.onCreate = { [weak self] tracker in
                self?.addTracker(tracker)
            }
            vc = irregular
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func addTracker(_ tracker: Tracker) {
        let defaultTitle = "Важное"
        var newCategories = categories
        if let index = newCategories.firstIndex(where: { $0.title == defaultTitle }) {
            let updated = TrackerCategory(
                title: newCategories[index].title,
                trackers: newCategories[index].trackers + [tracker]
            )
            newCategories[index] = updated
        } else {
            newCategories.append(TrackerCategory(title: defaultTitle, trackers: [tracker]))
        }
        categories = newCategories

        shiftDateIfNeeded(for: tracker)
        reload()
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
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        reload()
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

    // MARK: TrackerCellDelegate

    func trackerCellDidToggleCompletion(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]

        let today = Calendar.iso8601Ru.startOfDay(for: Date())
        if currentDate > today {
            return
        }

        if let existing = completedTrackers.firstIndex(where: {
            $0.trackerId == tracker.id && Calendar.iso8601Ru.isDate($0.date, inSameDayAs: currentDate)
        }) {
            completedTrackers.remove(at: existing)
        } else {
            completedTrackers.append(TrackerRecord(trackerId: tracker.id, date: currentDate))
        }
        collectionView.reloadItems(at: [indexPath])
    }
}
