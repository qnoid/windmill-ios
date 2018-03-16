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
    
    func testGivenAccountAssertWindmills() {
        
        let accountResource = AccountResource()
                
        var actual: [Windmill]?
        
        let expectation = XCTestExpectation(description: #function)
        let dataTask = accountResource.requestWindmills(forAccount: "14810686-4690-4900-ADA5-8B0B7338AA39"){ windmills, error in
            
            guard let windmills = windmills else {
                XCTFail(error!.localizedDescription)
                return
            }

            actual = windmills
            expectation.fulfill()
        }
        
        dataTask.resume();
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotEqual(0, actual?.count)
    }
    
    func testGivenRequestRegisterDeviceAssertDevice() {
        
        let accountResource = AccountResource()
        let tokenString = "651743ecad5704a088ff54a0234f37a013bd17b3401d1612cb8ded8af1fa2225"
        
        var actual: Device?
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestRegisterDevice(forAccount: "14810686-4690-4900-ADA5-8B0B7338AA39", withToken: tokenString) { device, error in
            
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

            guard let _ = device else {
                XCTFail(error!.localizedDescription)
                return
            }

        }).responseString { response in
            
            actual = response.response?.statusCode
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(actual, 400)
    }
    
}
