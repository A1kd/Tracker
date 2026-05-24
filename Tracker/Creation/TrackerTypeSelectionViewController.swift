import UIKit

final class TrackerTypeSelectionViewController: UIViewController {

    var onSelect: ((TrackerType) -> Void)?

    private lazy var habitButton: UIButton = makeButton(title: "Привычка", action: #selector(habitTapped))
    private lazy var irregularButton: UIButton = makeButton(title: "Нерегулярное событие", action: #selector(irregularTapped))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Создание трекера"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]

        let stack = UIStackView(arrangedSubviews: [habitButton, irregularButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.backgroundColor = .ypBlackDay
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    @objc private func habitTapped() { onSelect?(.habit) }
    @objc private func irregularTapped() { onSelect?(.irregular) }
}
