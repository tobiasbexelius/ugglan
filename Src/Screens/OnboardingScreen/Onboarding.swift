//
//  Onboarding.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-19.
//

import Flow
import Foundation
import Presentation
import UIKit

struct Onboarding {}

extension Onboarding: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        switch Localization.Locale.currentLocale.market {
        case .se:
            return OnboardingChat().materialize()
        case .no:
            return WebOnboarding().materialize()
        }
    }
}