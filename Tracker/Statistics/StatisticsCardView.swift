import UIKit

final class StatisticsCardView: UIView {

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textColor = .ypBlackDay
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .ypBlackDay
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.masksToBounds = true

        gradientLayer.colors = [
            UIColor(hex: "#007BFA").cgColor,
            UIColor(hex: "#46E69D").cgColor,
            UIColor(hex: "#FD4C49").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.cornerRadius = 16
        layer.addSublayer(gradientLayer)

        shapeLayer.fillColor = UIColor.systemBackground.cgColor
        gradientLayer.mask = nil
        layer.addSublayer(shapeLayer)

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        let inner = bounds.insetBy(dx: 1, dy: 1)
        let path = UIBezierPath(roundedRect: inner, cornerRadius: 15)
        shapeLayer.path = path.cgPath
    }

    func configure(value: Int, title: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }
}
