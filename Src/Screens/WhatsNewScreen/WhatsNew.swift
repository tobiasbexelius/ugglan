//
//  WhatsNew.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-05.
//

import Apollo
import Foundation
import Flow
import Form
import Presentation
import UIKit

struct WhatsNew {
    let dataSignal: ReadWriteSignal<WhatsNewQuery.Data?>
    
    init(data: WhatsNewQuery.Data?) {
        self.dataSignal = ReadWriteSignal<WhatsNewQuery.Data?>(data)
    }
}

extension WhatsNew: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()

        viewController.preferredPresentationStyle = .modally(
            presentationStyle: .formSheetOrOverFullscreen,
            transitionStyle: nil,
            capturesStatusBarAppearance: nil
        )
        
        let closeButton = CloseButton()
    
        let item = UIBarButtonItem(viewable: closeButton)
        viewController.navigationItem.rightBarButtonItem = item
        
        viewController.displayableTitle = String(key: .FEATURE_PROMO_TITLE)
        
        let view = UIView()
        view.backgroundColor = .offWhite
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.width.centerX.centerY.equalToSuperview()
            make.height.equalToSuperview().inset(20)
        }
        
        let scrollToNextCallbacker = Callbacker<Void>()
        let scrolledToPageIndexCallbacker = Callbacker<Int>()
        let scrolledToEndCallbacker = Callbacker<Void>()
        
        let pager = WhatsNewPager(
            scrollToNextCallbacker: scrollToNextCallbacker,
            scrolledToPageIndexCallbacker: scrolledToPageIndexCallbacker,
            scrolledToEndCallbacker: scrolledToEndCallbacker,
            presentingViewController: viewController
        )
        
        bag += containerView.addArranged(pager) { pagerView in
            pagerView.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
            }
        }
        
        let controlsWrapper = UIStackView()
        controlsWrapper.axis = .vertical
        controlsWrapper.alignment = .center
        controlsWrapper.spacing = 16
        controlsWrapper.distribution = .equalSpacing
        controlsWrapper.isLayoutMarginsRelativeArrangement = true
        controlsWrapper.edgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        containerView.addArrangedSubview(controlsWrapper)
        
        controlsWrapper.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        let pagerDots = WhatsNewPagerDots()
        
        bag += controlsWrapper.addArranged(pagerDots) { pagerDotsView in
            pagerDotsView.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
                make.height.equalTo(20)
            }
        }
        
        let proceedButton = ProceedButton(
            button: Button(title: "", type: .standard(backgroundColor: .blackPurple, textColor: .white))
        )
        
        bag += controlsWrapper.addArranged(proceedButton)
       
        bag += dataSignal.atOnce().bindTo(pager.dataSignal)
        bag += dataSignal.atOnce().filter { $0 != nil }.map { data -> Int in data!.news.count }.bindTo(proceedButton.pageAmountSignal)
        bag += dataSignal.atOnce().filter { $0 != nil }.map { data -> Int in data!.news.count + 1 }.bindTo(pagerDots.pageAmountSignal)
        bag += dataSignal.atOnce().bindTo(proceedButton.dataSignal)
        
        bag += pager.scrolledToPageIndexCallbacker.bindTo(pagerDots.pageIndexSignal)
        bag += pager.scrolledToPageIndexCallbacker.bindTo(proceedButton.onScrolledToPageIndexSignal)
        
        bag += proceedButton.onTapSignal.onValue {
            scrollToNextCallbacker.callAll()
        }
        
        viewController.view = view
        
        return (viewController, Future { completion in
            bag += merge(
                closeButton.onTapSignal,
                scrolledToEndCallbacker.providedSignal
            ).onValue {
                ApplicationState.setLastNewsSeen()
                completion(.success)
            }
            
            return bag
        })
    }
}
