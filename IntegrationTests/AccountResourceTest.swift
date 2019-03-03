//
//  IntegrationTests.swift
//  IntegrationTests
//
//  Created by Markos Charatzas on 06/07/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import XCTest
import Alamofire

@testable import windmill

class AccountResourceTest: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    func testGivenAccountAssertExports() {
        
        let accountResource = AccountResource()
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjMzMTA4MTg4NTc0LCJ0eXAiOiJhdCIsInYiOjF9.rzEzm5S0N0fxb2mp83aFwOXduHRjKPI3m18cwkPaiqY"

        var actual: [windmill.Export]?
        
        let expectation = XCTestExpectation(description: #function)
        let dataTask = accountResource.requestExports(forAccount: "14810686-4690-4900-ada5-8b0b7338aa39", authorizationToken: SubscriptionAuthorizationToken(value: claim)){ exports, error in
            
            guard let exports = exports else {
                XCTFail(error!.localizedDescription)
                return
            }

            actual = exports
            expectation.fulfill()
        }
        
        dataTask.resume();
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotEqual(0, actual?.count)
    }
    
    func testGivenExpiredTokenAssertUnauthorisedExpired() {
        
        let accountResource = AccountResource()
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjAsInR5cCI6ImF0IiwidiI6MX0.O1WL0ny5pneJLYTtQR6Qti-EHxmLpcmO6T_cY-JsjUw"

        var actual: SubscriptionError?

        let expectation = XCTestExpectation(description: #function)
        let dataTask = accountResource.requestExports(forAccount: "14810686-4690-4900-ada5-8b0b7338aa39", authorizationToken: SubscriptionAuthorizationToken(value: claim)){ exports, error in
            
            actual = error as? SubscriptionError
            expectation.fulfill()
        }
        
        dataTask.resume();
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(actual?.isUnauthorised ?? false)
        XCTAssertTrue(actual?.isExpired ?? false)
    }
    
    func testGivenRequestRegisterDeviceAssertDevice() {
        
        let accountResource = AccountResource()
        let tokenString = "651743ecad5704a088ff54a0234f37a013bd17b3401d1612cb8ded8af1fa2225"
        
        var actual: Device?
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestRegisterDevice(forAccount: "14810686-4690-4900-ada5-8b0b7338aa39", withToken: tokenString) { device, error in
            
        guard let device = device else {
            XCTFail(error!.localizedDescription)
            return
        }
            
        actual = device
        expectation.fulfill()
            
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(actual?.token, tokenString)
    }
    
    func testGivenRequestRegisterDeviceForUnknownAccountAssertError() {
        
        let accountResource = AccountResource()
        let tokenString = "e14113c658cd67f35a870433f4218d51233eba0cbdc02c88e80adaad1dcc94c6"
        
        var actual: NSInteger?
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestRegisterDevice(forAccount: "uknown_account_identifier", withToken: tokenString, completion: { device, error in

        }).responseString { response in
            
            actual = response.response?.statusCode
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(actual, 400)
    }
    
}
