//
//  PriceBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Ease
import Flow
import Form
import Foundation
import UIKit

struct PriceBubble {
    let containerScrollView: UIScrollView
    let dataSignal = ReadWriteSignal<OfferQuery.Data?>(nil)
}

extension PriceBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)
        containerView.isLayoutMarginsRelativeArrangement = true

        bag += containerScrollView.contentOffsetSignal.onValue { contentOffset in
            containerView.transform = CGAffineTransform(
                translationX: 0,
                y: (contentOffset.y / 5)
            )
        }

        let bubbleView = UIView()
        containerView.addArrangedSubview(bubbleView)
        bubbleView.backgroundColor = .secondaryBackground

        let stackView = CenterAllStackView()
        stackView.axis = .vertical
        stackView.alignment = .center

        bubbleView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let grossPriceLabel = UILabel(value: "", style: TextStyle.priceBubbleGrossTitle)
        grossPriceLabel.animationSafeIsHidden = true

        stackView.addArrangedSubview(grossPriceLabel)

        let priceLabel = UILabel(value: "", style: TextStyle.largePriceBubbleTitle)

        bag += bubbleView.windowSignal.compactMap { $0 }.onValue({ window in
            if window.frame.height < 700 {
                bubbleView.snp.makeConstraints({ make in
                    make.width.height.equalTo(125)
                })
                priceLabel.style = TextStyle.largePriceBubbleTitle.resized(to: 40)
                bubbleView.layer.cornerRadius = 125 / 2
            } else {
                bubbleView.snp.makeConstraints({ make in
                    make.width.height.equalTo(180)
                })
                priceLabel.style = TextStyle.largePriceBubbleTitle
                bubbleView.layer.cornerRadius = 180 / 2
            }
        })

        let ease: Ease<CGFloat> = Ease(0, minimumStep: 1)

        let grossPriceSignal = dataSignal
            .compactMap { $0?.insurance.cost?.fragments.costFragment.monthlyGross.amount }
            .toInt()
            .compactMap { $0 }

        let discountSignal = dataSignal
            .compactMap { $0?.insurance.cost?.fragments.costFragment.monthlyDiscount.amount }
            .toInt()
            .compactMap { $0 }

        bag += combineLatest(discountSignal, grossPriceSignal)
            .animated(style: SpringAnimationStyle.mediumBounce(), animations: { monthlyDiscount, monthlyGross in
                grossPriceLabel.styledText = StyledText(text: "\(monthlyGross) kr/mån", style: TextStyle.priceBubbleGrossTitle)
                grossPriceLabel.animationSafeIsHidden = monthlyDiscount == 0
                grossPriceLabel.alpha = monthlyDiscount == 0 ? 0 : 1
            })

        let monthlyNetPriceSignal = dataSignal
            .compactMap { $0?.insurance.cost?.fragments.costFragment.monthlyNet.amount }
            .toInt()
            .compactMap { $0 }
            .buffer()

        bag += discountSignal.onValue { value in
            if value > 0 {
                priceLabel.textColor = .pink
            } else {
                priceLabel.textColor = TextStyle.largePriceBubbleTitle.color
            }
        }

        bag += monthlyNetPriceSignal.onValue({ values in
            guard let value = values.last else { return }

            if values.count == 1 {
                ease.value = CGFloat(value)
            }

            ease.targetValue = CGFloat(value)
        })

        bag += ease.addSpring(tension: 300, damping: 100, mass: 2) { number in
            if number != 0 {
                priceLabel.text = String(Int(number))
            }
        }

        stackView.addArrangedSubview(priceLabel)

        bag += stackView.addArranged(MultilineLabel(value: "kr/mån", style: TextStyle.rowSubtitle.centerAligned))

        let campaignTypeSignal = dataSignal.map { $0?.redeemedCampaigns.first }.map { campaign -> CampaignBubble.CampaignType? in
            let incentiveFragment = campaign?.fragments.campaignFragment.incentive?.fragments.incentiveFragment

            if let freeMonths = incentiveFragment?.asFreeMonths {
                return CampaignBubble.CampaignType.freeMonths(number: freeMonths.quantity ?? 0)
            }

            if incentiveFragment?.asMonthlyCostDeduction != nil {
                return CampaignBubble.CampaignType.invited
            }

            return nil
        }

        let campaignBubble = CampaignBubble(campaignTypeSignal: campaignTypeSignal)
        bag += bubbleView.add(campaignBubble) { campaignBubbleView in
            campaignBubbleView.snp.makeConstraints { make in
                make.right.equalTo(60)
                make.top.equalTo(0)
            }
        }

        bubbleView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: -30))
        bubbleView.alpha = 0

        bag += dataSignal.toVoid().delay(by: 0.75)
            .animated(style: SpringAnimationStyle.mediumBounce()) { _ in
                bubbleView.alpha = 1
                bubbleView.transform = CGAffineTransform.identity
            }

        return (containerView, bag)
    }
}