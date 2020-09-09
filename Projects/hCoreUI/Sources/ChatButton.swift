//
//  ChatButton.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-09.
//

import Flow
import FlowFeedback
import Foundation
import hCore
import UIKit

public struct ChatButton {
    public static var openChatHandler: (_ self: Self) -> Void = { _ in }
    public let presentingViewController: UIViewController

    public init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
}

extension UIViewController {
    /// installs a chat button in the navigation bar to the right
    public func installChatButton() {
        let chatButton = ChatButton(presentingViewController: self)
        let item = UIBarButtonItem(viewable: chatButton)
        navigationItem.rightBarButtonItem = item
    }
}

extension ChatButton: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let chatButtonView = UIControl()
        chatButtonView.backgroundColor = .brand(.primaryBackground())

        bag += chatButtonView.signal(for: \.bounds).atOnce().onValue { frame in
            chatButtonView.layer.cornerRadius = frame.height / 2
        }

        bag += chatButtonView.signal(for: .touchUpInside).feedback(type: .impactLight)

        bag += chatButtonView.signal(for: .touchUpInside).onValue { _ in
            Self.openChatHandler(self)
        }

        let chatIcon = UIImageView()
        chatIcon.image = hCoreUIAssets.chat.image
        chatIcon.contentMode = .scaleAspectFit
        chatIcon.tintColor = .brand(.primaryText())

        bag += chatButtonView.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.25), animations: { _ in
            chatButtonView.backgroundColor = UIColor.brand(.primaryBackground()).darkened(amount: 0.1)
        })

        bag += chatButtonView.delayedTouchCancel().animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
            chatButtonView.backgroundColor = .brand(.primaryBackground())
        }

        chatButtonView.addSubview(chatIcon)

        chatIcon.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.45)
            make.height.equalToSuperview().multipliedBy(0.45)
            make.center.equalToSuperview()
        }

        chatButtonView.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(40)
        }

        return (chatButtonView, bag)
    }
}