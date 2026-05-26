import UIKit

final class TrackerSectionHeaderView: UICollectionReusableView {

    static let reuseID = "TrackerSectionHeaderView"

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
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
