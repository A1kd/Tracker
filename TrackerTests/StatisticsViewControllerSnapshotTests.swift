import XCTest
import SnapshotTesting
@testable import Tracker

final class StatisticsViewControllerSnapshotTests: XCTestCase {

    func test_statisticsScreen_empty_light() {
        let vc = StatisticsViewController()
        let nav = UINavigationController(rootViewController: vc)
        assertSnapshot(of: nav, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func test_statisticsScreen_empty_dark() {
        let vc = StatisticsViewController()
        let nav = UINavigationController(rootViewController: vc)
        assertSnapshot(of: nav, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
