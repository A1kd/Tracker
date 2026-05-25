import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let onboardingDefaultsKey = "onboardingCompleted"

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeRootViewController()
        self.window = window
        window.makeKeyAndVisible()
    }

    private func makeRootViewController() -> UIViewController {
        if UserDefaults.standard.bool(forKey: onboardingDefaultsKey) {
            return MainTabBarController()
        }
        let onboarding = OnboardingPageViewController()
        onboarding.onFinish = { [weak self] in
            self?.completeOnboarding()
        }
        return onboarding
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: onboardingDefaultsKey)
        guard let window else { return }
        let main = MainTabBarController()
        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve) {
            window.rootViewController = main
        }
    }
}
