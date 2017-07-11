//
//  windmillTests.swift
//  windmillTests
//
//  Created by Markos Charatzas on 04/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import XCTest
@testable import windmill

class windmillTests: XCTestCase {

    func testGivenAccountAssertWindmills() {
        self.continueAfterFailure = false
        
        let expectation = self.expectation(description: #function)
        
        var actual: [Windmill]?
        
        let accountResource = AccountResource()
        
        let dataTask = accountResource.requestWindmills(forAccount: "14810686-4690-4900-ADA5-8B0B7338AA39"){ windmills, error in
            
            actual = windmills
            expectation.fulfill()
        }
        
        dataTask.resume();
        self.waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(actual)
        XCTAssertNotEqual(0, actual!.count)
    }
}
