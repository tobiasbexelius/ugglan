//
//  TerminatedInsurance.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-19.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit

struct TerminatedInsurance {}

extension TerminatedInsurance: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()

        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 20

        let spacing = Spacing(height: 20)
        bag += view.addArranged(spacing)

        let title = MultilineLabel(value: L10n.insuranceStatusTerminatedAlertTitle, style: .standaloneLargeTitle)
        bag += view.addArranged(title)

        let description = MultilineLabel(value: L10n.insuranceStatusTerminatedAlertMessage, style: TextStyle.bodyOffBlack.centerAligned)
        bag += view.addArranged(description)

        let button = Button(
            title: L10n.insuranceStatusTerminatedAlertCta,
            type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor)
        )
        bag += view.addArranged(button)

        bag += button.onTapSignal.onValue { _ in
            let overlay = DraggableOverlay(presentable: FreeTextChat(), adjustsToKeyboard: false)
            viewController.present(overlay)
        }

        bag += viewController.install(view) { scrollView in
            scrollView.backgroundColor = .offWhite
        }

        return (viewController, bag)
    }
}