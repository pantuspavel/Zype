//
//  ZypeUITests.swift
//  ZypeUITests
//
//  Created by Pavel Pantus on 3/11/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//

import XCTest

class ZypeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testScroll() {
        XCUIApplication().tables.staticTexts["Drone Test Windy"].swipeUp()
    }
}
