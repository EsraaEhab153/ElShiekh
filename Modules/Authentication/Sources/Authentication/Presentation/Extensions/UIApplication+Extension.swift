//
//  UIApplication+Extension.swift
//  Authentication
//

import UIKit

public extension UIApplication {
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let baseController = controller ?? connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController

        if let navigationController = baseController as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = baseController as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = baseController?.presentedViewController {
            return topViewController(controller: presented)
        }
        return baseController
    }
}
