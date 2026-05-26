import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeRootViewController()
        self.window = window
        window.makeKeyAndVisible()
    }

    private func makeRootViewController() -> UIViewController {
        if UserDefaultsService.shared.isOnboardingCompleted {
            return MainTabBarController()
        }
        let onboarding = OnboardingPageViewController()
        onboarding.onFinish = { [weak self] in
            self?.completeOnboarding()
        }
        return onboarding
    }

    private func completeOnboarding() {
        UserDefaultsService.shared.isOnboardingCompleted = true
        guard let window else { return }
        let main = MainTabBarController()
        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve) {
            window.rootViewController = main
        }
    }
}
