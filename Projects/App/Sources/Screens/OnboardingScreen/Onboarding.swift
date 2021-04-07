import Flow
import Foundation
import hCore
import Presentation
import UIKit
import Embark

struct Onboarding {}

extension Onboarding: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        switch Localization.Locale.currentLocale.market {
        case .se:
            ApplicationState.preserveState(.onboarding)
            return OnboardingChat().materialize()
        case .dk:
            let (viewController, future) = WebOnboarding(webScreen: .webOnboarding).materialize()
            return (viewController, future.disposable)
        case .no:
            return EmbarkOnboardingFlow().materialize()
        }
    }
}
