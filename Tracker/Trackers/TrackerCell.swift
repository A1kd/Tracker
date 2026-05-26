import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidToggleCompletion(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {

    static let reuseID = "TrackerCell"
    weak var delegate: TrackerCellDelegate?

    private let cardView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emojiBackground: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .white
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let counterLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .ypBlackDay
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 17
        b.tintColor = .white
        b.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView)
        cardView.addSubview(emojiBackground)
        emojiBackground.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        contentView.addSubview(counterLabel)
        contentView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiBackground.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackground.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            counterLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            actionButton.centerYAnchor.constraint(equalTo: counterLabel.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(with tracker: Tracker, isCompleted: Bool, count: Int) {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.name
        counterLabel.text = dayString(for: count)

        let symbol = isCompleted ? SystemImages.checkmarkSmall : SystemImages.plusSmall
        actionButton.setImage(symbol, for: .normal)
        actionButton.backgroundColor = isCompleted
            ? tracker.color.withAlphaComponent(0.3)
            : tracker.color
    }

    private func dayString(for count: Int) -> String {
        let mod100 = count % 100
        let mod10 = count % 10
        if mod100 >= 11 && mod100 <= 14 { return "\(count) дней" }
        if mod10 == 1 { return "\(count) день" }
        if mod10 >= 2 && mod10 <= 4 { return "\(count) дня" }
        return "\(count) дней"
    }

    @objc private func actionTapped() {
        delegate?.trackerCellDidToggleCompletion(self)
    }
}
