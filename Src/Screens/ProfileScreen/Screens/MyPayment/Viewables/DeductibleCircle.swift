//
//  MonthlyCostCircle.swift
//  Hedvig
//
//  Created by Isaac Sennerholt on 2019-01-15.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit
import ComponentKit

struct DeductibleCircle {}

extension DeductibleCircle: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIView()

        let deductibleCircleText = DynamicString(String(key: .MY_PAYMENT_DEDUCTIBLE_CIRCLE))

        let deductibleCircle = CircleLabelSmall(
            labelText: deductibleCircleText,
            textColor: .hedvig(.offWhite),
            backgroundColor: UIColor(dynamic: { trait -> UIColor in
                trait.userInterfaceStyle == .dark ? .hedvig(.secondaryBackground) : .hedvig(.darkGreen)
            })
        )

        bag += containerView.add(deductibleCircle)

        bag += containerView.didLayoutSignal.take(first: 1).onValue { _ in
            containerView.snp.makeConstraints { make in
                make.height.equalTo(80)
                make.centerX.equalToSuperview().offset(80)
                make.bottom.equalTo(0)
            }
        }

        return (containerView, bag)
    }
}
