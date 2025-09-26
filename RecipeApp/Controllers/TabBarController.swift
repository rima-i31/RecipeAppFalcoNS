

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    var addButton: UIBarButtonItem?
    var toggleSearch: UIBarButtonItem?
    var toggleFav: UIBarButtonItem?
    var k = K()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
    @objc func handleMemoryWarning() {
        let defaults = UserDefaults.standard
        
        if let appDomain = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: appDomain)
        }
        defaults.synchronize()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            if let authViewController = storyboard.instantiateInitialViewController() {
                window.rootViewController = authViewController
                window.makeKeyAndVisible()
            }
        }
    }
}
