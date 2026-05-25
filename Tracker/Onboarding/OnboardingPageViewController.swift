import UIKit

final class OnboardingPageViewController: UIPageViewController {

    var onFinish: (() -> Void)?

    private let pages: [OnboardingContentViewController]

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = pages.count
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .ypBlackDay
        pc.pageIndicatorTintColor = .ypBlackDay.withAlphaComponent(0.3)
        pc.isUserInteractionEnabled = false
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    init() {
        let page1 = OnboardingContentViewController(
            pageIndex: 0,
            image: UIImage(named: "OnboardingBg1"),
            title: "Отслеживайте только то, что хотите"
        )
        let page2 = OnboardingContentViewController(
            pageIndex: 1,
            image: UIImage(named: "OnboardingBg2"),
            title: "Даже если это\nне литры воды и йога"
        )
        self.pages = [page1, page2]
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        page1.onDone = { [weak self] in self?.onFinish?() }
        page2.onDone = { [weak self] in self?.onFinish?() }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: false)
        }

        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -168),
        ])
    }
}

// MARK: - DataSource

extension OnboardingPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnboardingContentViewController,
              let index = pages.firstIndex(of: current),
              index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnboardingContentViewController,
              let index = pages.firstIndex(of: current),
              index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

// MARK: - Delegate

extension OnboardingPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let current = viewControllers?.first as? OnboardingContentViewController else { return }
        pageControl.currentPage = current.pageIndex
    }
}
