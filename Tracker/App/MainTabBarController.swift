import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabs()
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
    }

    private func setupTabs() {
        let trackersVC = TrackersViewController()
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: SystemImages.recordCircleFill,
            selectedImage: SystemImages.recordCircleFill
        )

        let statsVC = StatisticsViewController()
        let statsNav = UINavigationController(rootViewController: statsVC)
        statsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: SystemImages.hareFill,
            selectedImage: SystemImages.hareFill
        )

        viewControllers = [trackersNav, statsNav]
    }
}
