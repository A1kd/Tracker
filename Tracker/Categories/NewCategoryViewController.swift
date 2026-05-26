import UIKit

final class NewCategoryViewController: UIViewController {

    var onCreate: ((String) -> Void)?

    private lazy var nameField: PaddedTextField = {
        let f = PaddedTextField()
        f.placeholder = "Введите название категории"
        f.font = .systemFont(ofSize: 17)
        f.backgroundColor = .ypBackgroundDay
        f.layer.cornerRadius = 16
        f.clearButtonMode = .whileEditing
        f.translatesAutoresizingMaskIntoConstraints = false
        f.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        return f
    }()

    private lazy var doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Готово", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.backgroundColor = .ypGray
        b.layer.cornerRadius = 16
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новая категория"

        view.addSubview(nameField)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc private func nameChanged() {
        let trimmed = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let enabled = !trimmed.isEmpty
        doneButton.isEnabled = enabled
        doneButton.backgroundColor = enabled ? .ypBlackDay : .ypGray
    }

    @objc private func doneTapped() {
        let trimmed = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return }
        let callback = onCreate
        navigationController?.popViewController(animated: true)
        callback?(trimmed)
    }
}
