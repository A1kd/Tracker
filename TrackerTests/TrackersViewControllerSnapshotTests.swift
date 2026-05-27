import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {

    func test_trackersScreen_light() {
        let vc = TrackersViewController()
        let nav = UINavigationController(rootViewController: vc)
        assertSnapshot(of: nav, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func test_trackersScreen_dark() {
        let vc = TrackersViewController()
        let nav = UINavigationController(rootViewController: vc)
        assertSnapshot(of: nav, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
