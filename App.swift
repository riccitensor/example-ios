import Visualix
import UIKit
import UserNotifications

@UIApplicationMain final class App: UINavigationController, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private(set) static weak var shared: App!
    var window: UIWindow?
    
    func alert(_ title: String, message: String) {
        UNUserNotificationCenter.current().add({
            $0.title = title
            $0.body = message
            return UNNotificationRequest(identifier: UUID().uuidString, content: $0, trigger: nil)
        } (UNMutableNotificationContent()))
    }
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        App.shared = self
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.backgroundColor = .black
        window!.makeKeyAndVisible()
        window!.rootViewController = self
        
        Configuration.shared.load()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
        return true
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent:
        UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [willPresent.request.identifier])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
        interactivePopGestureRecognizer!.isEnabled = false
        
        let controller = UIViewController()
        controller.view.backgroundColor = .black
        pushViewController(controller, animated: false)
        
        let logo = UIImageView(image: #imageLiteral(resourceName: "logo.pdf"))
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.clipsToBounds = true
        logo.contentMode = .center
        controller.view.addSubview(logo)
        
        let map = button(.local("App.map"), selector: #selector(self.map))
        let place = button(.local("App.place"), selector: #selector(self.place))
        let user = button(.local("App.user"), selector: #selector(self.user))
        let settings = button(.local("App.settings"), selector: #selector(self.settings))
        settings.backgroundColor = .blue
        settings.setTitleColor(.white, for: [])
        
        logo.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
        logo.bottomAnchor.constraint(equalTo: controller.view.centerYAnchor, constant: -70).isActive = true
        
        map.topAnchor.constraint(equalTo: controller.view.centerYAnchor, constant: -20).isActive = true
        place.topAnchor.constraint(equalTo: map.bottomAnchor, constant: 20).isActive = true
        user.topAnchor.constraint(equalTo: place.bottomAnchor, constant: 20).isActive = true
        settings.topAnchor.constraint(equalTo: user.bottomAnchor, constant: 20).isActive = true
    }
    
    private func button(_ title: String, selector: Selector) -> UIButton {
        let button = UIButton()
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: [])
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(UIColor(white: 0, alpha: 0.1), for: .highlighted)
        button.titleLabel!.font = .systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 6
        viewControllers.first!.view.addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: viewControllers.first!.view.centerXAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 150).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }
    
    @objc private func map() {
        if viewControllers.count < 2 {
            pushViewController(Map(), animated: true)
        }
    }
    
    @objc private func place() {
        if viewControllers.count < 2 {
            pushViewController(Place(), animated: true)
        }
    }
    
    @objc private func user() {
        if viewControllers.count < 2 {
            pushViewController(User(), animated: true)
        }
    }
    
    @objc private func settings() {
        if viewControllers.count < 2 {
            pushViewController(Settings(), animated: true)
        }
    }
}
