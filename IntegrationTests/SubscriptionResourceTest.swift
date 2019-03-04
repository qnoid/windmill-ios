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

        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJiY0ROTzd6TXp4Q290QXJ1dlJleCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsInR5cCI6ImZvbyIsInYiOjF9.5p1dxT8R7io1cRzi-La8116AruCrw0QJ_XRSTVO_7ME"
        
        var actual: SubscriptionError?

        let expectation = XCTestExpectation(description: #function)

        subscriptionResource.requestSubscription(claim: SubscriptionClaim(value: claim)) { (token, error) in
            
            actual = error as? SubscriptionError
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(actual?.isUnauthorised ?? false)
    }

    func testGivenExpiredClaimAssertUnauthorisedExpired() {
        
        let subscriptionResource = SubscriptionResource()
        
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJpOGVkZTE1OFhkdHpVZUFYZVFEbSIsInN1YiI6IjU1RkQyQUMzLTdERTItNEM2Ny1CMEY4LTc5RTdDRkEwMjBDMiIsInR5cCI6InN1YiIsInYiOjF9.j9TRWYwXSp8KPhDXS9P1Cz-L2ldBwlZ8Gb4EssLvHzw"
        
        var actual: SubscriptionError?
        
        let expectation = XCTestExpectation(description: #function)
        
        subscriptionResource.requestSubscription(claim: SubscriptionClaim(value: claim)) { (token, error) in
            
            actual = error as? SubscriptionError
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(actual?.isUnauthorised ?? false)
        XCTAssertTrue(actual?.isExpired ?? false)
    }

    func testGivenNoneSignatureClaimAssertUnauthorised() {
        
        let subscriptionResource = SubscriptionResource()
        
        let claim = "eyJhbGciOiJub25lIn0.eyJqdGkiOiJiY0ROTzd6TXp4Q290QXJ1dlJleCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsInR5cCI6InN1YiIsInYiOjF9.j9TRWYwXSp8KPhDXS9P1Cz-L2ldBwlZ8Gb4EssLvHzw"
        
        var actual: SubscriptionError?

        let expectation = XCTestExpectation(description: #function)
        
        subscriptionResource.requestSubscription(claim: SubscriptionClaim(value: claim)) { (token, error) in
            
            actual = error as? SubscriptionError
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(actual?.isUnauthorised ?? false)
    }

}
