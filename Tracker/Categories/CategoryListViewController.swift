import UIKit

final class CategoryListViewController: UIViewController {

    private let viewModel: CategoryListViewModel
    var onSelectCategory: ((String) -> Void)?

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = .ypBackgroundDay
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.backgroundColor = .clear
        t.separatorColor = .ypGray.withAlphaComponent(0.3)
        t.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        t.tableFooterView = UIView()
        t.rowHeight = 75
        t.dataSource = self
        t.delegate = self
        t.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseID)
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    private lazy var addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Добавить категорию", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.backgroundColor = .ypBlackDay
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return b
    }()

    private lazy var emptyStateView: EmptyStateView = {
        let v = EmptyStateView(
            image: UIImage(named: "EmptyTrackers"),
            title: "Привычки и события можно\nобъединить по смыслу"
        )
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    init(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Категория"

        view.addSubview(container)
        container.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(lessThanOrEqualTo: addButton.topAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: container.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
        ])

        bindViewModel()
        refreshUI()
    }

    private func bindViewModel() {
        viewModel.onItemsChange = { [weak self] _ in
            self?.refreshUI()
        }
        viewModel.onSelect = { [weak self] title in
            self?.navigationController?.popViewController(animated: true)
            self?.onSelectCategory?(title)
        }
    }

    private func refreshUI() {
        let isEmpty = viewModel.numberOfRows == 0
        container.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.reloadData()
    }

    @objc private func addTapped() {
        let vc = NewCategoryViewController()
        vc.onCreate = { [weak self] title in
            self?.viewModel.addCategory(title: title)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableView

extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseID, for: indexPath) as! CategoryCell
        cell.configure(with: viewModel.item(at: indexPath.row))
        let isLast = indexPath.row == viewModel.numberOfRows - 1
        cell.separatorInset = isLast
            ? UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
            : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectRow(at: indexPath.row)
    }
}
