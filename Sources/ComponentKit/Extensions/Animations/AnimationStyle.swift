//
//  AnimationStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

public struct AnimationStyle {
    public var options: UIView.AnimationOptions
    public var duration: TimeInterval
    public var delay: TimeInterval

    public init(options: UIView.AnimationOptions, duration: TimeInterval, delay: TimeInterval) {
        self.options = options
        self.duration = duration
        self.delay = delay
    }
}

public extension AnimationStyle {
    static func easeOut(duration: TimeInterval, delay: TimeInterval = 0) -> AnimationStyle {
        return AnimationStyle(options: .curveEaseOut, duration: duration, delay: delay)
    }

    static func easeIn(duration: TimeInterval, delay: TimeInterval = 0) -> AnimationStyle {
        return AnimationStyle(options: .curveEaseIn, duration: duration, delay: delay)
    }

    static func linear(duration: TimeInterval, delay: TimeInterval = 0) -> AnimationStyle {
        return AnimationStyle(options: .curveLinear, duration: duration, delay: delay)
    }
}