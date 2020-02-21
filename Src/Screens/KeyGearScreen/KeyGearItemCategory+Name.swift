//
//  KeyGearItemCategory+Name.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-20.
//

import Foundation

extension KeyGearItemCategory {
    var name: String {
        switch self {
        case .computer:
            return String(key: .ITEM_TYPE_COMPUTER)
        case .phone:
            return String(key: .ITEM_TYPE_PHONE)
        case .tv:
            return String(key: .ITEM_TYPE_TV)
        case .jewelry:
            return String(key: .ITEM_TYPE_JEWELRY)
        case .bike:
            return String(key: .ITEM_TYPE_BIKE)
        case .watch:
            return String(key: .ITEM_TYPE_WATCH)
        case .smartWatch:
            return "TODO smart watch"
        case .__unknown:
            return ""
        }
    }
}