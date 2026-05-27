import UIKit

// MARK: - PaddedTextField

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

// MARK: - Section header

final class TrackerFormSectionHeader: UICollectionReusableView {
    static let reuseID = "TrackerFormSectionHeader"

    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 19, weight: .bold)
        l.textColor = .ypBlackDay
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}

// MARK: - TextField cell

final class TrackerNameCell: UICollectionViewCell {
    static let reuseID = "TrackerNameCell"

    private(set) lazy var textField: PaddedTextField = {
        let f = PaddedTextField()
        f.placeholder = "Введите название трекера"
        f.font = .systemFont(ofSize: 17)
        f.backgroundColor = .ypBackgroundDay
        f.layer.cornerRadius = 16
        f.clearButtonMode = .whileEditing
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    let errorLabel: UILabel = {
        let l = UILabel()
        l.text = "Ограничение 38 символов"
        l.font = .systemFont(ofSize: 17)
        l.textColor = .ypRed
        l.textAlignment = .center
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let counterLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textColor = .ypBlackDay
        l.textAlignment = .center
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var textFieldTopToTop: NSLayoutConstraint?
    private var textFieldTopToCounter: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(counterLabel)
        contentView.addSubview(textField)
        contentView.addSubview(errorLabel)
        textFieldTopToTop = textField.topAnchor.constraint(equalTo: contentView.topAnchor)
        textFieldTopToCounter = textField.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 24)
        textFieldTopToTop?.isActive = true
        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            counterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75),

            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func setError(_ visible: Bool) {
        errorLabel.isHidden = !visible
    }

    func setCounter(_ text: String?) {
        if let text {
            counterLabel.text = text
            counterLabel.isHidden = false
            textFieldTopToTop?.isActive = false
            textFieldTopToCounter?.isActive = true
        } else {
            counterLabel.isHidden = true
            textFieldTopToCounter?.isActive = false
            textFieldTopToTop?.isActive = true
        }
    }
}

// MARK: - Menu cell (combined Категория/Расписание container)

protocol MenuCellDelegate: AnyObject {
    func menuCellDidTapCategory(_ cell: MenuCell)
    func menuCellDidTapSchedule(_ cell: MenuCell)
}

final class MenuCell: UICollectionViewCell {
    static let reuseID = "MenuCell"

    weak var delegate: MenuCellDelegate?

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = .ypBackgroundDay
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let categoryRow = MenuRowView(title: "Категория")
    let scheduleRow = MenuRowView(title: "Расписание")
    let separator = UIView()

    private var scheduleHeightConstraint: NSLayoutConstraint?
    private var separatorHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        separator.backgroundColor = .ypGray.withAlphaComponent(0.3)
        separator.translatesAutoresizingMaskIntoConstraints = false
        categoryRow.translatesAutoresizingMaskIntoConstraints = false
        scheduleRow.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(container)
        container.addSubview(categoryRow)
        container.addSubview(separator)
        container.addSubview(scheduleRow)

        scheduleHeightConstraint = scheduleRow.heightAnchor.constraint(equalToConstant: 75)
        separatorHeightConstraint = separator.heightAnchor.constraint(equalToConstant: 0.5)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            categoryRow.topAnchor.constraint(equalTo: container.topAnchor),
            categoryRow.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            categoryRow.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            categoryRow.heightAnchor.constraint(equalToConstant: 75),

            separator.topAnchor.constraint(equalTo: categoryRow.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            separatorHeightConstraint!,

            scheduleRow.topAnchor.constraint(equalTo: separator.bottomAnchor),
            scheduleRow.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scheduleRow.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scheduleHeightConstraint!,
            scheduleRow.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        categoryRow.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        scheduleRow.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func showSchedule(_ show: Bool) {
        scheduleRow.isHidden = !show
        separator.isHidden = !show
        scheduleHeightConstraint?.constant = show ? 75 : 0
        separatorHeightConstraint?.constant = show ? 0.5 : 0
        layoutIfNeeded()
    }

    @objc private func categoryTapped() { delegate?.menuCellDidTapCategory(self) }
    @objc private func scheduleTapped() { delegate?.menuCellDidTapSchedule(self) }
}

// MARK: - Emoji cell

final class EmojiCell: UICollectionViewCell {
    static let reuseID = "EmojiCell"

    private let backgroundBadge: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundBadge)
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            backgroundBadge.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            backgroundBadge.widthAnchor.constraint(equalToConstant: 52),
            backgroundBadge.heightAnchor.constraint(equalToConstant: 52),

            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(emoji: String, selected: Bool) {
        emojiLabel.text = emoji
        backgroundBadge.backgroundColor = selected ? .ypLightGray : .clear
    }
}

// MARK: - Color cell

final class ColorCell: UICollectionViewCell {
    static let reuseID = "ColorCell"

    private let colorView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(color: UIColor, selected: Bool) {
        colorView.backgroundColor = color
        contentView.layer.borderColor = selected ? color.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
    }
}
