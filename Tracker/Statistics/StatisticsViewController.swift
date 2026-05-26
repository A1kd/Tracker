import UIKit

final class StatisticsViewController: UIViewController {

    private let calculator = StatisticsCalculator(
        trackerStore: TrackerStore(),
        recordStore: TrackerRecordStore()
    )

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let bestPeriodCard = StatisticsCardView()
    private let idealDaysCard = StatisticsCardView()
    private let completedCard = StatisticsCardView()
    private let averageCard = StatisticsCardView()

    private lazy var emptyStateView: EmptyStateView = {
        let v = EmptyStateView(
            image: UIImage(resource: .emptyTrackers),
            title: "Анализировать пока нечего"
        )
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = L10n.statisticsTab
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        view.addSubview(emptyStateView)

        stack.addArrangedSubview(makeCardContainer(bestPeriodCard))
        stack.addArrangedSubview(makeCardContainer(idealDaysCard))
        stack.addArrangedSubview(makeCardContainer(completedCard))
        stack.addArrangedSubview(makeCardContainer(averageCard))

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func makeCardContainer(_ card: StatisticsCardView) -> UIView {
        card.translatesAutoresizingMaskIntoConstraints = false
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: container.topAnchor),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            card.heightAnchor.constraint(equalToConstant: 90),
        ])
        return container
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    private func refresh() {
        let stats = calculator.compute()
        bestPeriodCard.configure(value: stats.bestPeriod, title: "Лучший период")
        idealDaysCard.configure(value: stats.idealDays, title: "Идеальные дни")
        completedCard.configure(value: stats.totalCompleted, title: "Трекеров завершено")
        averageCard.configure(value: stats.averagePerDay, title: "Среднее значение")

        let empty = stats.isEmpty
        scrollView.isHidden = empty
        emptyStateView.isHidden = !empty
    }
}
