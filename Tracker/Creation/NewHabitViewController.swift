import UIKit

final class NewHabitViewController: UIViewController {

    var onCreate: ((Tracker) -> Void)?

    private let defaultCategoryTitle = "Важное"
    private var selectedSchedule: [WeekDay] = []

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.keyboardDismissMode = .onDrag
        return s
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 24
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private lazy var nameField: PaddedTextField = {
        let f = PaddedTextField()
        f.placeholder = "Введите название трекера"
        f.font = .systemFont(ofSize: 17)
        f.backgroundColor = .ypBackgroundDay
        f.layer.cornerRadius = 16
        f.heightAnchor.constraint(equalToConstant: 75).isActive = true
        f.clearButtonMode = .whileEditing
        f.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        return f
    }()

    private let optionsContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .ypBackgroundDay
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()

    private lazy var categoryRow: MenuRowView = {
        let r = MenuRowView(title: "Категория")
        r.setSubtitle(defaultCategoryTitle)
        return r
    }()

    private lazy var scheduleRow: MenuRowView = {
        let r = MenuRowView(title: "Расписание")
        r.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
        return r
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новая привычка"
        setupLayout()
    }

    private func setupLayout() {
        let separator = UIView()
        separator.backgroundColor = .ypGray.withAlphaComponent(0.3)
        separator.translatesAutoresizingMaskIntoConstraints = false

        categoryRow.translatesAutoresizingMaskIntoConstraints = false
        scheduleRow.translatesAutoresizingMaskIntoConstraints = false
        optionsContainer.addSubview(categoryRow)
        optionsContainer.addSubview(separator)
        optionsContainer.addSubview(scheduleRow)

        contentStack.addArrangedSubview(nameField)
        contentStack.addArrangedSubview(optionsContainer)

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -16),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            categoryRow.topAnchor.constraint(equalTo: optionsContainer.topAnchor),
            categoryRow.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            categoryRow.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            categoryRow.heightAnchor.constraint(equalToConstant: 75),

            separator.topAnchor.constraint(equalTo: categoryRow.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 0.5),

            scheduleRow.topAnchor.constraint(equalTo: separator.bottomAnchor),
            scheduleRow.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            scheduleRow.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            scheduleRow.heightAnchor.constraint(equalToConstant: 75),
            scheduleRow.bottomAnchor.constraint(equalTo: optionsContainer.bottomAnchor),

            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func updateCreateButtonState() {
        let hasName = !(nameField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let hasSchedule = !selectedSchedule.isEmpty
        let enabled = hasName && hasSchedule
        createButton.isEnabled = enabled
        createButton.backgroundColor = enabled ? .ypBlackDay : .ypGray
    }

    private func scheduleSubtitle() -> String? {
        guard !selectedSchedule.isEmpty else { return nil }
        if selectedSchedule.count == WeekDay.allCases.count { return "Каждый день" }
        return selectedSchedule
            .sorted { $0.rawValue < $1.rawValue }
            .map { $0.shortName }
            .joined(separator: ", ")
    }

    @objc private func nameChanged() {
        updateCreateButtonState()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func createTapped() {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespaces), !name.isEmpty else { return }
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: UIColor.trackerPalette.first ?? .ypRed,
            emoji: "😪",
            schedule: selectedSchedule
        )
        dismiss(animated: true) { [weak self] in
            self?.onCreate?(tracker)
        }
    }

    @objc private func scheduleTapped() {
        let vc = ScheduleViewController()
        vc.selectedDays = Set(selectedSchedule)
        vc.onDone = { [weak self] days in
            self?.selectedSchedule = Array(days)
            self?.scheduleRow.setSubtitle(self?.scheduleSubtitle())
            self?.updateCreateButtonState()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class PaddedTextField: UITextField {
    private let inset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 41)
    override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: inset) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: inset) }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: inset) }
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let r = super.clearButtonRect(forBounds: bounds)
        return r.offsetBy(dx: -12, dy: 0)
    }
}
