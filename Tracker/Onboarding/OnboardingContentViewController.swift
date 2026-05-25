import UIKit

final class OnboardingContentViewController: UIViewController {

    let pageIndex: Int
    var onDone: (() -> Void)?

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textColor = .ypBlackDay
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Вот это технологии!", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.backgroundColor = .ypBlackDay
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return b
    }()

    init(pageIndex: Int, image: UIImage?, title: String) {
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
        backgroundImageView.image = image
        titleLabel.text = title
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -160),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -84),
        ])
    }

    @objc private func doneTapped() {
        onDone?()
    }
}
