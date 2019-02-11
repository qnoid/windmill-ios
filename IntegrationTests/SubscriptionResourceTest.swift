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

    func testGivenValidTransactionReceiptAssertToken() {
        
        let receiptURL = Bundle(for: SubscriptionResourceTest.self).url(forResource: "receipt", withExtension: "data")!
        let receiptData = try! Data(contentsOf: receiptURL)
        let receipt = String(data: receiptData, encoding: .utf8)!.replacingOccurrences(of: "\n", with: "")
        
        let subscriptionResource = SubscriptionResource()
        
        var actual: ReceiptClaim?
        
        let expectation = XCTestExpectation(description: #function)
        
        subscriptionResource.requestTransactions(forReceipt: receipt) { (account, claim, error) in
            
            guard let claim = claim else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            actual = claim
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(actual)
    }

}
