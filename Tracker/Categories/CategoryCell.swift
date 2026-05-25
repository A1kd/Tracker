import UIKit

final class CategoryCell: UITableViewCell {

    static let reuseID = "CategoryCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17)
        l.textColor = .ypBlackDay
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tintColor = .ypBlue
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkImageView.leadingAnchor, constant: -8),

            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: CategoryListItem) {
        titleLabel.text = item.title
        checkmarkImageView.isHidden = !item.isSelected
    }
}
