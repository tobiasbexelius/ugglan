//
//  ReadWriteSignal+Static.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-03.
//

import Flow
import Foundation

extension ReadWriteSignal {
    static func `static`<Value>(_ value: Value) -> ReadWriteSignal<Value> {
        ReadWriteSignal(value)
    }
}