//
//  TabBarController.swift
//  RacePace
//
//  Created by Austin Louden on 5/24/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        tabBar.isTranslucent = false

        let viewController = PaceViewController()
        let projections = ProjectionsViewController()
        
        projections.tabBarItem = UITabBarItem(title: NSLocalizedString("Your paces", comment: "Your paces"), image: UIImage(named: "icon-watch"), selectedImage: nil)
        viewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Pace tables", comment: "Pace tables"), image: UIImage(named: "icon-clipboard"), selectedImage: nil)
        
        viewControllers = [viewController, projections].map { UINavigationController(rootViewController: $0) }
    }
}
