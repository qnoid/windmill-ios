//
//  ProductsManager.swift
//  windmill
//
//  Created by Markos Charatzas on 06/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit
import StoreKit

protocol SubscriptionManagerDelegate: NSObjectProtocol {
    
    func success(_ manager: SubscriptionManager, products: [SKProduct])
    func success(_ manager: SubscriptionManager, receipt: URL)
    func error(_ manager: SubscriptionManager, didFailWithError error: Error)
}

extension SubscriptionManagerDelegate {
    
    func success(_ manager: SubscriptionManager, products: [SKProduct]) {}
    func success(_ manager: SubscriptionManager, receipt: URL) {}
    func error(_ manager: SubscriptionManager, didFailWithError error: Error) {}
}

class SubscriptionManager: NSObject, SKProductsRequestDelegate {
    
    struct Product {
        enum Identifier: String {
            case individualMonthly = "io.windmill.windmill.individual_monthly"
        }
        static let isIndividualMonthly: (SKProduct) -> Bool = { SubscriptionManager.Product.Identifier(rawValue: $0.productIdentifier) == .individualMonthly }
        
        static let individualMonthly = Product(identifier: .individualMonthly, duration: "month")
        
        let identifier: Product.Identifier
        let duration: String
    }
    
    let subscriptionResource = SubscriptionResource()
    
    var products: [SKProduct]? {
        didSet {
            if let products = products {
                self.delegate?.success(self, products: products)
            }
        }
    }
    
    var delegate: SubscriptionManagerDelegate?
    
    func requestTransactions(receiptData: String, completion: @escaping SubscriptionResource.TransactionsCompletion) {
        
        self.subscriptionResource.requestTransactions(forReceipt: receiptData) { (account, receiptClaim, error) in
            
            switch error {
            case .some(let error):
                completion(account, receiptClaim, error)
            case .none:
                if let claim = receiptClaim?.value, let account = account?.identifier {
                    try? ApplicationStorage.default.write(value: claim,
                                                          key: .receiptClaim,
                                                          options: .completeFileProtectionUnlessOpen)
                    try? ApplicationStorage.default.write(value: account,
                                                          key: .account,
                                                          options: .completeFileProtectionUntilFirstUserAuthentication)
                }
                
                completion(account, receiptClaim, error)
            }
        }
    }

    func productsRequest(productIdentifiers: [Product.Identifier] = [.individualMonthly]) -> SKProductsRequest {
        
        let productsRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers.compactMap{ $0.rawValue }))
        productsRequest.delegate = self
        productsRequest.start()
        
        return productsRequest
    }
    
    func receiptRefreshRequest() -> SKReceiptRefreshRequest {
        
        let receiptRefreshRequest = SKReceiptRefreshRequest()
        receiptRefreshRequest.delegate = self
        receiptRefreshRequest.start()
        
        return receiptRefreshRequest
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
    
    func requestDidFinish(_ request: SKRequest) {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            return
        }
        
        self.delegate?.success(self, receipt: appStoreReceiptURL)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.delegate?.error(self, didFailWithError: error)
    }
}
