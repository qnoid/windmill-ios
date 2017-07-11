//
//  IntegrationTests.swift
//  IntegrationTests
//
//  Created by Markos Charatzas on 06/07/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import XCTest

@testable import windmill

class AccountResourceTest: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    func testExample() {
        
        let accountResource = AccountResource()
        let tokenString = "e14113c658cd67f35a870433f4218d51233eba0cbdc02c88e80adaad1dcc94c6"
        
        var actual: Device?
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestRegisterDevice(forAccount: "14810686-4690-4900-ADA5-8B0B7338AA39", withToken: tokenString) { device, error in
            
        guard let device = device else {
            XCTFail(error!.localizedDescription)
            return
        }
            
        actual = device
        expectation.fulfill()
            
        }.resume()
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual?.token, tokenString)
    }
    
    func testExample2() {
        
        let accountResource = AccountResource()
        let tokenString = "e14113c658cd67f35a870433f4218d51233eba0cbdc02c88e80adaad1dcc94c6"
        
        var actual: Device?
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestRegisterDevice(forAccount: "account", withToken: tokenString) { device, error in
            
            guard let device = device else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            actual = device
            expectation.fulfill()
            
            }.resume()
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual?.token, tokenString)
    }
    
}
