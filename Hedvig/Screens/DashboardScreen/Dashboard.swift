//
//  Dashboard.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Presentation
import UIKit

struct Dashboard {}

extension Dashboard: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(.DASHBOARD_BANNER_ACTIVE_TITLE(firstName: "hej"))

        let view = UIView()
        view.backgroundColor = .purple

        viewController.view = view

        return (viewController, bag)
    }
}

extension Dashboard: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: String(.TAB_DASHBOARD_TITLE),
            image: Asset.dashboardTab.image,
            selectedImage: nil
        )
    }
}