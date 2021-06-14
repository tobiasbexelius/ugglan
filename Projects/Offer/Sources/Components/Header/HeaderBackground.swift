//
//  Header.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Form
import hCore
import hCoreUI
import Flow
import Presentation

struct HeaderBackground {}

extension HeaderBackground: Presentable {
    func materialize() -> (UIView, Disposable) {
        let view = UIView()
        let bag = DisposeBag()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
          UIColor(red: 0.921, green: 0.825, blue: 0.834, alpha: 1).cgColor,
          UIColor(red: 0.85, green: 0.82, blue: 0.946, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 2.94, tx: 0, ty: -0.97))
        view.layer.addSublayer(gradientLayer)
        
        bag += view.didLayoutSignal.onValue { _ in
            gradientLayer.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
            gradientLayer.position = view.center
        }
        
        return (view, bag)
    }
}