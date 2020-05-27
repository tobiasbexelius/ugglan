//
//  UIView+AnimationSafeIsHidden.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-31.
//

import Foundation
import UIKit

public extension UIView {
    /// Workaround for the UIStackView bug where setting hidden to true with animation doesn't work
    var animationSafeIsHidden: Bool {
        get {
            return isHidden
        }
        set {
            if isHidden != newValue {
                isHidden = newValue
            }
        }
    }
}