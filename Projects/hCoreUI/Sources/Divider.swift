//
//  Divider.swift
//  Hedvig
//
//  Created by Axel Backlund on 2019-04-05.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
import UIKit

public struct Divider {
    public let backgroundColor: UIColor
    
    public init(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
    }
}

extension Divider: Viewable {
    public func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let divider = UIView()

        let bag = DisposeBag()

        divider.backgroundColor = backgroundColor

        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        return (divider, bag)
    }
}