import UIKit

final class FilterListViewController: UIViewController {

    var onSelect: ((TrackerFilter) -> Void)?

    private let filters: [TrackerFilter] = TrackerFilter.allCases
    private var selectedFilter: TrackerFilter

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = .ypBackgroundDay
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var tableView: SelfSizingTableView = {
        let t = SelfSizingTableView(frame: .zero, style: .plain)
        t.backgroundColor = .clear
        t.separatorColor = .ypGray.withAlphaComponent(0.3)
        t.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        t.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        t.tableFooterView = UIView()
        t.sectionHeaderTopPadding = 0
        t.contentInsetAdjustmentBehavior = .never
        t.isScrollEnabled = false
        t.rowHeight = 75
        t.dataSource = self
        t.delegate = self
        t.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseID)
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    init(currentFilter: TrackerFilter) {
        self.selectedFilter = currentFilter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Фильтры"

        view.addSubview(container)
        container.addSubview(tableView)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: container.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }
}

extension FilterListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseID, for: indexPath) as! CategoryCell
        let filter = filters[indexPath.row]
        let shouldShowCheckmark = filter.isActive && filter == selectedFilter
        cell.configure(with: CategoryListItem(title: filter.title, isSelected: shouldShowCheckmark))
        let isLast = indexPath.row == filters.count - 1
        cell.separatorInset = isLast
            ? UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
            : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        let callback = onSelect
        dismiss(animated: true) {
            callback?(filter)
        }
    }
}
