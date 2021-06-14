//
//  Header.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Form
import hCore
import hCoreUI
import Flow
import Presentation

struct Header {
    let scrollView: UIScrollView
    static let trailingAlignmentBreakpoint: CGFloat = 800
    static let trailingAlignmentFormPercentageWidth: CGFloat = 0.40
    static let insetTop: CGFloat = 30
}

extension Header: Presentable {
    func materialize() -> (UIStackView, Disposable) {
        let view = UIStackView()
        view.allowTouchesOfViewsOutsideBounds = true
        view.axis = .vertical
        let bag = DisposeBag()
        
        view.edgeInsets = UIEdgeInsets(top: Self.insetTop, left: 15, bottom: 60, right: 15)
        
        bag += view.add(GradientView(
            gradientOption: .init(
                preset: .insuranceOne,
                shouldShimmer: false,
                shouldAnimate: false
            ),
            shouldShowGradientSignal: .init(true)
        )) { headerBackgroundView in
            headerBackgroundView.layer.masksToBounds = true
            headerBackgroundView.layer.zPosition = -1
            headerBackgroundView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.edges.equalToSuperview()
            }
            
            bag += scrollView.signal(for: \.contentOffset).atOnce().onValue { contentOffset in
                let headerScaleFactor: CGFloat = -(contentOffset.y) / headerBackgroundView.bounds.height
                
                guard headerScaleFactor > 0 else {
                    headerBackgroundView.layer.transform = CATransform3DIdentity
                    return
                }
                                
                var headerTransform = CATransform3DIdentity
                
                let headerSizevariation = ((headerBackgroundView.bounds.height * (1.0 + headerScaleFactor)) - headerBackgroundView.bounds.height) / 2.0
                
                headerTransform = CATransform3DTranslate(headerTransform, 0, -headerSizevariation, 0)
                headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
                
                headerBackgroundView.layer.transform = headerTransform
            }
        }
        
        let formContainer = UIStackView()
        formContainer.axis = .vertical
        formContainer.alignment = .trailing
        formContainer.isLayoutMarginsRelativeArrangement = true
        formContainer.insetsLayoutMarginsFromSafeArea = true
        view.addArrangedSubview(formContainer)
        
        bag += formContainer.addArrangedSubview(HeaderForm()) { form, _ in
            bag += merge(
                formContainer.didLayoutSignal,
                view.didLayoutSignal
            ).onValue {
                form.snp.remakeConstraints { make in
                    if view.frame.width > Self.trailingAlignmentBreakpoint {
                        formContainer.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
                        make.width.equalTo(view.frame.width * Self.trailingAlignmentFormPercentageWidth - max(view.safeAreaInsets.right, 15) - 15)
                    } else {
                        formContainer.layoutMargins = .zero
                        make.width.equalToSuperview()
                    }
                }
            }
            
            bag += scrollView.signal(for: \.contentOffset).atOnce().onValue { contentOffset in
                if let navigationBar = view.viewController?.navigationController?.navigationBar,
                   let insetTop = view.viewController?.navigationController?.view.safeAreaInsets.top {
                    let contentOffsetY = contentOffset.y + navigationBar.frame.height + insetTop
                    if view.frame.width > Self.trailingAlignmentBreakpoint, contentOffsetY > 0 {
                        formContainer.transform = CGAffineTransform(translationX: 0, y: contentOffsetY)
                    } else {
                        formContainer.transform = CGAffineTransform.identity
                    }
                }
               
            }
        }
                
        return (view, bag)
    }
}