//
//  IntegrationTests.swift
//  IntegrationTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 06/07/2017.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs"

        var actual: [windmill.Export]?
        
        let expectation = XCTestExpectation(description: #function)
        let dataTask = accountResource.requestExports(forAccount: Account(identifier: "14810686-4690-4900-ada5-8b0b7338aa39"), authorizationToken: SubscriptionAuthorizationToken(value: claim)){ exports, error in
            
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
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MCwidHlwIjoiYXQiLCJ2IjoxfQ.P-ajI8U1I1sjlFuRNOpJctRDd9rgktiErhsnbbnVlwE"

        var actual: SubscriptionError?

        let expectation = XCTestExpectation(description: #function)
        let dataTask = accountResource.requestExports(forAccount: Account(identifier: "14810686-4690-4900-ada5-8b0b7338aa39"), authorizationToken: SubscriptionAuthorizationToken(value: claim)){ exports, error in
            
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
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs"

        var actual: Device?
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestDevice(forAccount: Account(identifier: "14810686-4690-4900-ada5-8b0b7338aa39"), withToken: tokenString, authorizationToken: SubscriptionAuthorizationToken(value: claim)) { device, error in
            
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
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs"

        var actual: NSInteger?
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestDevice(forAccount: Account(identifier: "uknown_account_identifier"), withToken: tokenString, authorizationToken: SubscriptionAuthorizationToken(value: claim), completion: { device, error in

        }).responseString { response in
            
            actual = response.response?.statusCode
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(actual, 400)
    }
}
