//
//  AttachGIFButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-07-30.
//

import Flow
import Foundation
import UIKit

struct AttachGIFButton {
    let isOpenSignal: ReadSignal<Bool>
}

extension AttachGIFButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIControl, Signal<Void>) {
        let bag = DisposeBag()
        let control = UIControl()
        control.backgroundColor = .purple
        control.layer.cornerRadius = 20

        control.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }

        let icon = Icon(icon: Asset.gif, iconWidth: 20)
        control.addSubview(icon)

        icon.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.center.equalToSuperview()
        }

        let touchUpInside = control.signal(for: .touchUpInside)

        bag += touchUpInside.feedback(type: .impactLight)

        bag += control.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
            control.backgroundColor = UIColor.purple.darkened(amount: 0.1)
        }

        bag += merge(
            touchUpInside,
            control.signal(for: .touchCancel),
            control.signal(for: .touchUpOutside)
        ).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
            control.backgroundColor = UIColor.purple
        }

        return (control, Signal { callback in
            bag += touchUpInside.onValue(callback)
            return bag
        })
    }
}
