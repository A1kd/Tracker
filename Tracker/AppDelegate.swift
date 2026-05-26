import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private let appMetricaKey = "e69127c9-8646-4ea8-8b31-ce790fde6ecc"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AnalyticsService.shared.activate(apiKey: appMetricaKey)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
