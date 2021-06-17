//
//  Array+Disposable.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-04-22.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

extension Array where Element: Disposable {
	public var disposable: Disposable {
		DisposeBag(self)
	}
}
