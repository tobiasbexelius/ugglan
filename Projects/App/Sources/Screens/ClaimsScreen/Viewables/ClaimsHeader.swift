//
//  ClaimsHeader.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-04-23.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct ClaimsHeader {
    let presentingViewController: UIViewController
    @Inject var client: ApolloClient

    init(
        presentingViewController: UIViewController
    ) {
        self.presentingViewController = presentingViewController
    }

    struct Title {}
    struct Description {}
    struct InactiveMessage {
        @Inject var client: ApolloClient
    }
}

extension ClaimsHeader.Title: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center

        let bag = DisposeBag()

        let label = MultilineLabel(
            value: L10n.claimsHeaderTitle,
            style: TextStyle.standaloneLargeTitle.centered()
        )

        bag += view.addArranged(label) { view in
            view.snp.makeConstraints { make in
                make.top.equalTo(10)
                make.width.equalToSuperview().multipliedBy(0.7)
            }
        }

        return (view, bag)
    }
}

extension ClaimsHeader.Description: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center

        let bag = DisposeBag()

        let label = MultilineLabel(
            value: L10n.claimsHeaderSubtitle,
            style: TextStyle.body.centered()
        )

        bag += view.addArranged(label) { view in
            view.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.8)
            }
        }

        return (view, bag)
    }
}

extension ClaimsHeader.InactiveMessage: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.isHidden = true

        let bag = DisposeBag()

        let card = UIView()
        card.backgroundColor = .secondaryBackground
        card.layer.cornerRadius = 10

        view.addArrangedSubview(card)

        card.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let cardContent = UIStackView()
        cardContent.axis = .vertical
        cardContent.alignment = .center
        cardContent.isLayoutMarginsRelativeArrangement = true
        cardContent.edgeInsets = UIEdgeInsets(horizontalInset: 24, verticalInset: 24)
        cardContent.alpha = 0
        card.addSubview(cardContent)

        cardContent.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let label = MultilineLabel(
            value: L10n.claimsInactiveMessage,
            style: TextStyle.bodyOffBlack.centered()
        )

        bag += cardContent.addArranged(label) { view in
            view.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.8)
                make.center.equalToSuperview()
            }
        }

        let isEligibleDataSignal = client.watch(query: EligibleToCreateClaimQuery()).compactMap { $0.data?.isEligibleToCreateClaim }

        bag += isEligibleDataSignal
            .wait(until: view.hasWindowSignal)
            .filter { !$0 }
            .delay(by: 0.5)
            .animated(style: SpringAnimationStyle.lightBounce()) { _ in
                bag += Signal(after: 0.25).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                    cardContent.alpha = 1
                }

                view.isHidden = false
            }

        return (view, bag)
    }
}

extension ClaimsHeader: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
        view.axis = .vertical
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 15
        let bag = DisposeBag()

        let inactiveMessage = InactiveMessage()
        bag += view.addArranged(inactiveMessage)

        let imageView = UIImageView()
        imageView.tintColor = .primaryTintColor
        imageView.image = Asset.claimsHeader.image
        imageView.contentMode = .scaleAspectFit

        view.addArrangedSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.height.equalTo(300)
        }

        let title = Title()
        bag += view.addArranged(title)

        let description = Description()
        bag += view.addArranged(description)

        let button = Button(title: L10n.claimsHeaderActionButton, type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor))

        bag += button.onTapSignal.onValue {
            self.presentingViewController.present(
                DraggableOverlay(
                    presentable: HonestyPledge(),
                    presentationOptions: [
                        .defaults,
                        .prefersLargeTitles(false),
                        .largeTitleDisplayMode(.never),
                        .prefersNavigationBarHidden(true),
                    ],
                    adjustsToKeyboard: false
                )
            )
        }

        bag += view.addArranged(button.wrappedIn(UIStackView())) { stackView in
            let isEligibleDataSignal = client.watch(query: EligibleToCreateClaimQuery()).compactMap { $0.data?.isEligibleToCreateClaim }
            bag += isEligibleDataSignal.bindTo(stackView, \.isUserInteractionEnabled)
            bag += isEligibleDataSignal
                .map { $0 ? 1 : 0.5 }
                .animated(style: AnimationStyle.easeOut(duration: 0.25)) { alpha in
                    stackView.alpha = alpha
                }
        }

        return (view, bag)
    }
}