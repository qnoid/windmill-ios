//
//  SubscriptionResourceTest.swift
//  IntegrationTests
//
//  Created by Markos Charatzas on 27/01/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import XCTest
import Alamofire
@testable import windmill

class SubscriptionResourceTest: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testGivenInvalidTransactionReceiptAssertError() {
        
        let subscriptionResource = SubscriptionResource()
        
        var actual: Error?
        
        let expectation = XCTestExpectation(description: #function)

        subscriptionResource.requestTransactions(forReceipt: "vuRiNscyxrlB24Eh9VW9KQ=") { (account, token, error) in
            
            guard let error = error else {
                XCTFail()
                return
            }
            
            actual = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        let error = actual as? AFError
        XCTAssertNotNil(error)
        XCTAssertEqual(403, error?.responseCode)
    }

    func testGivenExpiredTransactionReceiptAssertSubscriptionExpired() {
        
        let receiptURL = Bundle(for: SubscriptionResourceTest.self).url(forResource: "receipt", withExtension: "data")!
        let receiptData = try! Data(contentsOf: receiptURL)
        let receipt = String(data: receiptData, encoding: .utf8)!.replacingOccurrences(of: "\n", with: "")
        
        let subscriptionResource = SubscriptionResource()
        
        var actual: SubscriptionError?
        
        let expectation = XCTestExpectation(description: #function)
        
        subscriptionResource.requestTransactions(forReceipt: receipt) { (account, claim, error) in
            
            actual = error as? SubscriptionError
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(actual?.isExpired ?? false)
    }
    
    func testGivenInvalidClaimTypAssertUnauthorised() {
        
        let subscriptionResource = SubscriptionResource()

        let account = "14810686-4690-4900-ada5-8b0b7338aa38";
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJiY0ROTzd6TXp4Q290QXJ1dlJleCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjE1NTA3NDk4NzgsInR5cCI6ImZvbyIsInYiOjF9.GqSAmeZsJJfsKrqmp-DXBd1qO8TclTZ591V1MQ_6cuI"
        
        var actual: SubscriptionError?

        let expectation = XCTestExpectation(description: #function)

        subscriptionResource.requestSubscription(account: account, claim: SubscriptionClaim(value: claim)) { (token, error) in
            
            actual = error as? SubscriptionError
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(actual?.isUnauthorised ?? false)
    }

    func testGivenExpiredClaimAssertUnauthorisedExpired() {
        
        let subscriptionResource = SubscriptionResource()
        
        let account = "14810686-4690-4900-ada5-8b0b7338aa38";
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJiY0ROTzd6TXp4Q290QXJ1dlJleCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjAsInR5cCI6InN1YiIsInYiOjF9.HqwXYJPM0ZMv3hzxGk4kSjzGhwwYa0VkIURdDisWBks"
        
        var actual: SubscriptionError?
        
        let expectation = XCTestExpectation(description: #function)
        
        subscriptionResource.requestSubscription(account: account, claim: SubscriptionClaim(value: claim)) { (token, error) in
            
            actual = error as? SubscriptionError
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(actual?.isUnauthorised ?? false)
        XCTAssertTrue(actual?.isExpired ?? false)
    }

    func testGivenNoneSignatureClaimAssertUnauthorised() {
        
        let subscriptionResource = SubscriptionResource()
        
        let account = "14810686-4690-4900-ada5-8b0b7338aa38";
        let claim = "eyJhbGciOiJub25lIn0.eyJqdGkiOiJiY0ROTzd6TXp4Q290QXJ1dlJleCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTQiLCJleHAiOjE1NTA4NDk4NzgsInR5cCI6InN1YiIsInYiOjF9.fCZLoen435voR0sj2_2tY-1sk13f0gwR8y9Tb-vhClQ"
        
        var actual: SubscriptionError?

        let expectation = XCTestExpectation(description: #function)
        
        subscriptionResource.requestSubscription(account: account, claim: SubscriptionClaim(value: claim)) { (token, error) in
            
            actual = error as? SubscriptionError
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(actual?.isUnauthorised ?? false)
    }

}
