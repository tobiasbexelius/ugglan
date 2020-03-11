//
//  KeyGearCategoryButton.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-13.
//

import Flow
import Form
import Foundation
import UIKit
import Space
import ComponentKit

extension CGSize {
    func append(inset: UIEdgeInsets) -> CGSize {
        return CGSize(width: width + inset.left + inset.right, height: height + inset.bottom + inset.top)
    }
}

struct KeyGearCategoryButton: SignalProvider {
    let category: KeyGearItemCategory
    let selectedSignal = ReadWriteSignal<Bool>(false)
    private let callbacker = Callbacker<Void>()

    var providedSignal: Signal<Void> {
        callbacker.providedSignal
    }

    func calculateSize() -> CGSize {
        let attributedString = NSAttributedString(styledText: StyledText(
            text: category.rawValue,
            style: .blockRowTitle
        ))

        let rect = attributedString.boundingRect(
            with: CGSize(width: 1000, height: 1000),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        return rect.size.append(inset: UIEdgeInsets(inset: 10))
    }
}

extension KeyGearCategoryButton: Equatable {
    static func == (lhs: KeyGearCategoryButton, rhs: KeyGearCategoryButton) -> Bool {
        lhs.category == rhs.category
    }
}

extension KeyGearCategoryButton: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (KeyGearCategoryButton) -> Disposable) {
        let control = UIControl()
        control.backgroundColor = .hedvig(.primaryBackground)
        control.layer.cornerRadius = 8

        let contentContainer = UIStackView()
        contentContainer.isUserInteractionEnabled = false
        contentContainer.layoutMargins = UIEdgeInsets(inset: 10)
        contentContainer.isLayoutMarginsRelativeArrangement = true
        control.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let label = UILabel(value: "", style: .bodySmallSmallCenter)
        contentContainer.addArrangedSubview(label)

        return (control, { `self` in
            let bag = DisposeBag()

            bag += control.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.25)) {
                control.backgroundColor = UIColor.hedvig(.primaryTintColor).withAlphaComponent(0.2)
            }

            bag += control.delayedTouchCancel().animated(style: AnimationStyle.easeOut(duration: 0.25)) {
                control.backgroundColor = UIColor.hedvig(.primaryBackground)
            }

            bag += control.signal(for: .touchDown).feedback(type: .selection)

            bag += control.trackedTouchUpInsideSignal.atValue { _ in
                self.callbacker.callAll()
            }.animated(style: AnimationStyle.easeOut(duration: 0.25)) {
                self.selectedSignal.value = true
            }

            bag += self.selectedSignal.atOnce().animated(style: AnimationStyle.easeOut(duration: 0.25)) { selected in
                if selected {
                    control.layer.borderColor = UIColor.hedvig(.primaryTintColor).cgColor
                    control.layer.borderWidth = 1
                    label.style = TextStyle.bodySmallSmallCenter.colored(.hedvig(.primaryTintColor))
                } else {
                    control.layer.borderWidth = 0
                    label.style = TextStyle.bodySmallSmallCenter
                }
            }

            control.accessibilityLabel = self.category.rawValue
            label.value = self.category.name
            return bag
        })
    }
}
