import UIKit

final class ScheduleViewController: UIViewController {

    var selectedDays: Set<WeekDay> = []
    var onDone: ((Set<WeekDay>) -> Void)?

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .ypBackgroundDay
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.dataSource = self
        t.backgroundColor = .clear
        t.separatorStyle = .singleLine
        t.separatorColor = .ypGray.withAlphaComponent(0.3)
        t.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        t.rowHeight = 75
        t.isScrollEnabled = false
        t.register(ScheduleDayCell.self, forCellReuseIdentifier: ScheduleDayCell.reuseID)
        return t
    }()

    private lazy var doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Готово", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.backgroundColor = .ypBlackDay
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Расписание"

        view.addSubview(containerView)
        containerView.addSubview(tableView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75 * 7),

            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc private func doneTapped() {
        onDone?(selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleDayCell.reuseID, for: indexPath) as! ScheduleDayCell
        let day = WeekDay.allCases[indexPath.row]
        cell.configure(
            title: day.fullName,
            isOn: selectedDays.contains(day),
            isLast: indexPath.row == WeekDay.allCases.count - 1
        )
        cell.onToggle = { [weak self] isOn in
            guard let self else { return }
            if isOn { self.selectedDays.insert(day) }
            else    { self.selectedDays.remove(day) }
        }
        return cell
    }
}

final class ScheduleDayCell: UITableViewCell {

    static let reuseID = "ScheduleDayCell"
    var onToggle: ((Bool) -> Void)?

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17)
        l.textColor = .ypBlackDay
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var toggle: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .ypBlue
        s.translatesAutoresizingMaskIntoConstraints = false
        s.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return s
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggle)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            toggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, isOn: Bool, isLast: Bool) {
        titleLabel.text = title
        toggle.isOn = isOn
        if isLast {
            separatorInset = UIEdgeInsets(top: 0, left: bounds.width, bottom: 0, right: 0)
        } else {
            separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }

    @objc private func switchChanged() {
        onToggle?(toggle.isOn)
    }
}
