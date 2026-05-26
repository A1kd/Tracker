import UIKit

final class MenuRowView: UIControl {

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17)
        l.textColor = .ypBlackDay
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17)
        l.textColor = .ypGray
        return l
    }()

    private let chevronImageView: UIImageView = {
        let iv = UIImageView(image: SystemImages.chevronRight)
        iv.tintColor = .ypGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 2
        s.alignment = .leading
        return s
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        subtitleLabel.isHidden = true

        stack.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),

            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func setSubtitle(_ text: String?) {
        if let text, !text.isEmpty {
            subtitleLabel.text = text
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
}
