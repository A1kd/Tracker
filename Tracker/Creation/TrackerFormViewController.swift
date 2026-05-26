import UIKit

final class TrackerFormViewController: UIViewController {

    enum Section: Int, CaseIterable {
        case name
        case menu
        case emoji
        case color
    }

    var onCreate: ((Tracker, String) -> Void)?

    private let type: TrackerType
    private let nameLimit = 38

    private var name: String = ""
    private var selectedCategory: String = "Важное"
    private var selectedSchedule: [WeekDay] = []
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?
    private var showsNameError: Bool = false

    private let emojis: [String] = TrackerConstants.emojis
    private let palette: [UIColor] = UIColor.trackerPalette

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.keyboardDismissMode = .onDrag
        cv.allowsMultipleSelection = false
        cv.register(TrackerNameCell.self, forCellWithReuseIdentifier: TrackerNameCell.reuseID)
        cv.register(MenuCell.self, forCellWithReuseIdentifier: MenuCell.reuseID)
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseID)
        cv.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseID)
        cv.register(
            TrackerFormSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerFormSectionHeader.reuseID
        )
        return cv
    }()

    private lazy var cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Отменить", for: .normal)
        b.setTitleColor(.ypRed, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.ypRed.cgColor
        b.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return b
    }()

    private lazy var createButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Создать", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.backgroundColor = .ypGray
        b.layer.cornerRadius = 16
        b.isEnabled = false
        b.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        return b
    }()

    init(type: TrackerType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = type == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        navigationItem.hidesBackButton = true
        setupLayout()
        updateCreateButtonState()
    }

    private func setupLayout() {
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -16),

            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    // MARK: - Layout

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self, let section = Section(rawValue: sectionIndex) else { return nil }
            switch section {
            case .name:
                let height: NSCollectionLayoutDimension = .estimated(self.showsNameError ? 110 : 75)
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: height
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: height
                ), subitems: [item])
                let s = NSCollectionLayoutSection(group: group)
                s.contentInsets = .init(top: 24, leading: 16, bottom: 24, trailing: 16)
                return s
            case .menu:
                let height: CGFloat = self.type == .habit ? 150 : 75
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(height)
                ), subitems: [item])
                let s = NSCollectionLayoutSection(group: group)
                s.contentInsets = .init(top: 0, leading: 16, bottom: 32, trailing: 16)
                return s
            case .emoji, .color:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0 / 6.0),
                    heightDimension: .fractionalHeight(1.0)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(52)
                ), subitems: [item])
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(34)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                let s = NSCollectionLayoutSection(group: group)
                s.contentInsets = .init(top: 0, leading: 6, bottom: 24, trailing: 6)
                s.boundarySupplementaryItems = [header]
                return s
            }
        }
    }

    // MARK: - State

    private var isFormValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.count <= nameLimit else { return false }
        guard selectedEmojiIndex != nil else { return false }
        guard selectedColorIndex != nil else { return false }
        if type == .habit && selectedSchedule.isEmpty { return false }
        return true
    }

    private func updateCreateButtonState() {
        let enabled = isFormValid
        createButton.isEnabled = enabled
        createButton.backgroundColor = enabled ? .ypBlackDay : .ypGray
    }

    private func scheduleSubtitle() -> String? {
        guard !selectedSchedule.isEmpty else { return nil }
        if selectedSchedule.count == WeekDay.allCases.count { return "Каждый день" }
        return selectedSchedule
            .sorted { $0.rawValue < $1.rawValue }
            .map(\.shortName)
            .joined(separator: ", ")
    }

    private func reloadMenuCell() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: Section.menu.rawValue)) as? MenuCell {
            cell.categoryRow.setSubtitle(selectedCategory)
            cell.scheduleRow.setSubtitle(scheduleSubtitle())
        }
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func createTapped() {
        guard isFormValid,
              let emojiIndex = selectedEmojiIndex,
              let colorIndex = selectedColorIndex else { return }
        let tracker = Tracker(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            color: palette[colorIndex],
            emoji: emojis[emojiIndex],
            schedule: type == .habit ? selectedSchedule : []
        )
        let category = selectedCategory
        let callback = onCreate
        dismiss(animated: true) {
            callback?(tracker, category)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerFormViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .name, .menu: return 1
        case .emoji:       return emojis.count
        case .color:       return palette.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .name:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerNameCell.reuseID, for: indexPath) as! TrackerNameCell
            cell.textField.text = name
            cell.textField.delegate = self
            cell.textField.removeTarget(self, action: nil, for: .editingChanged)
            cell.textField.addTarget(self, action: #selector(nameChanged(_:)), for: .editingChanged)
            cell.setError(showsNameError)
            return cell
        case .menu:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCell.reuseID, for: indexPath) as! MenuCell
            cell.delegate = self
            cell.categoryRow.setSubtitle(selectedCategory)
            cell.showSchedule(type == .habit)
            if type == .habit {
                cell.scheduleRow.setSubtitle(scheduleSubtitle())
            }
            return cell
        case .emoji:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseID, for: indexPath) as! EmojiCell
            cell.configure(emoji: emojis[indexPath.item], selected: selectedEmojiIndex == indexPath.item)
            return cell
        case .color:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseID, for: indexPath) as! ColorCell
            cell.configure(color: palette[indexPath.item], selected: selectedColorIndex == indexPath.item)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerFormSectionHeader.reuseID,
            for: indexPath
        ) as! TrackerFormSectionHeader
        switch Section(rawValue: indexPath.section)! {
        case .emoji: header.titleLabel.text = "Emoji"
        case .color: header.titleLabel.text = "Цвет"
        default:     header.titleLabel.text = nil
        }
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerFormViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        switch Section(rawValue: indexPath.section)! {
        case .emoji, .color: return true
        default: return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .emoji:
            let oldIndex = selectedEmojiIndex
            selectedEmojiIndex = indexPath.item
            var paths: [IndexPath] = [indexPath]
            if let old = oldIndex, old != indexPath.item {
                paths.append(IndexPath(item: old, section: Section.emoji.rawValue))
            }
            collectionView.reloadItems(at: paths)
            updateCreateButtonState()
        case .color:
            let oldIndex = selectedColorIndex
            selectedColorIndex = indexPath.item
            var paths: [IndexPath] = [indexPath]
            if let old = oldIndex, old != indexPath.item {
                paths.append(IndexPath(item: old, section: Section.color.rawValue))
            }
            collectionView.reloadItems(at: paths)
            updateCreateButtonState()
        default: break
        }
    }
}

// MARK: - UITextFieldDelegate + name input

extension TrackerFormViewController: UITextFieldDelegate {

    @objc private func nameChanged(_ field: UITextField) {
        let text = field.text ?? ""
        if text.count > nameLimit {
            let trimmed = String(text.prefix(nameLimit))
            field.text = trimmed
            name = trimmed
            setShowsNameError(true)
        } else {
            name = text
            setShowsNameError(false)
        }
        updateCreateButtonState()
    }

    private func setShowsNameError(_ show: Bool) {
        guard showsNameError != show else { return }
        showsNameError = show
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: Section.name.rawValue)) as? TrackerNameCell {
            cell.setError(show)
        }
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - MenuCellDelegate

extension TrackerFormViewController: MenuCellDelegate {

    func menuCellDidTapCategory(_ cell: MenuCell) {
        let viewModel = CategoryListViewModel(selectedTitle: selectedCategory)
        let vc = CategoryListViewController(viewModel: viewModel)
        vc.onSelectCategory = { [weak self] title in
            guard let self else { return }
            self.selectedCategory = title
            self.reloadMenuCell()
            self.updateCreateButtonState()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func menuCellDidTapSchedule(_ cell: MenuCell) {
        let vc = ScheduleViewController()
        vc.selectedDays = Set(selectedSchedule)
        vc.onDone = { [weak self] days in
            guard let self else { return }
            self.selectedSchedule = Array(days)
            self.reloadMenuCell()
            self.updateCreateButtonState()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
