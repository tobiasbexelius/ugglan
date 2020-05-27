//
//  EmbarkInputTests.swift
//  EmbarkTests
//
//  Created by sam on 22.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import XCTest
@testable import Embark
import Testing
import SnapshotTesting

final class EmbarkInputTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }
    
    func testInput() {
        let embarkInput = EmbarkInput(placeholder: "Test 123")
        
        materializeViewable(embarkInput) { tooltipView in
            tooltipView.snp.makeConstraints { make in
                make.width.equalTo(300)
            }
            assertSnapshot(matching: tooltipView, as: .image)
        }
    }
}