import UIKit

final class NewIrregularEventViewController: UIViewController {

    var onCreate: ((Tracker) -> Void)?

    private let defaultCategoryTitle = "Важное"

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
        navigationItem.title = "Новое нерегулярное событие"
        setupLayout()
    }

    private func setupLayout() {
        categoryRow.translatesAutoresizingMaskIntoConstraints = false
        optionsContainer.addSubview(categoryRow)

        let contentStack = UIStackView(arrangedSubviews: [nameField, optionsContainer])
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentStack)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            categoryRow.topAnchor.constraint(equalTo: optionsContainer.topAnchor),
            categoryRow.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            categoryRow.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            categoryRow.heightAnchor.constraint(equalToConstant: 75),
            categoryRow.bottomAnchor.constraint(equalTo: optionsContainer.bottomAnchor),

            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc private func nameChanged() {
        let hasName = !(nameField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        createButton.isEnabled = hasName
        createButton.backgroundColor = hasName ? .ypBlackDay : .ypGray
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
            schedule: []
        )
        dismiss(animated: true) { [weak self] in
            self?.onCreate?(tracker)
        }
    }
}
