//
//  ProductsManager.swift
//  windmill
//
//  Created by Markos Charatzas on 06/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit
import Alamofire
import StoreKit
import os

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
    
    public static let SubscriptionCompletionIgnore: SubscriptionResource.SubscriptionCompletion = { token, error in
    
    }
    
    public static let SubscriptionPurchasing = Notification.Name("io.windmill.windmill.subscription.purchasing")
    public static let SubscriptionPurchased = Notification.Name("io.windmill.windmill.subscription.purchased")
    public static let SubscriptionFailed = Notification.Name("io.windmill.windmill.subscription.failed")
    public static let SubscriptionRestored: Notification.Name = Notification.Name(rawValue: "io.windmill.windmill.subscription.restored")
    public static let SubscriptionRestoreFailed: Notification.Name = Notification.Name(rawValue: "io.windmill.windmill.subscription.restore.failed")
    public static let SubscriptionActive = Notification.Name("io.windmill.windmill.subscription.active")
    public static let SubscriptionExpired = Notification.Name("io.windmill.windmill.subscription.expired")


    struct Product {
        enum Identifier: String {
            case individualMonthly = "io.windmill.windmill.individual_monthly"
        }
        static let isIndividualMonthly: (SKProduct) -> Bool = { SubscriptionManager.Product.Identifier(rawValue: $0.productIdentifier) == .individualMonthly }
        
        static let individualMonthly = Product(identifier: .individualMonthly, duration: "month")
        
        let identifier: Product.Identifier
        let duration: String
    }
    
    
    //This `SubscriptionManager` is meant to be used as a reasonable default. You shouldn't assume ownership when using this instance. i.e. Don't set its `delegate` and expect it to remain.
    static let shared: SubscriptionManager = SubscriptionManager()
    
    let subscriptionResource = SubscriptionResource()
    let accountResource = AccountResource()
    let paymentQueue: PaymentQueue
    
    var receiptRefreshRequest: SKReceiptRefreshRequest?
    var productsRequest: SKProductsRequest?
    
    var products: [SKProduct]? {
        didSet {
            if let products = products {
                self.delegate?.success(self, products: products)
            }
        }
    }
    
    var delegate: SubscriptionManagerDelegate?
    
    init(paymentQueue: PaymentQueue = PaymentQueue.default) {
        self.paymentQueue = paymentQueue
        super.init()
        self.paymentQueue.subscriptionManager = self
        NotificationCenter.default.addObserver(self, selector: #selector(transactionPurchasing(notification:)), name: PaymentQueue.TransactionPurchasing, object: paymentQueue)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionError(notification:)), name: PaymentQueue.TransactionError, object: paymentQueue)
        NotificationCenter.default.addObserver(self, selector: #selector(restoreCompletedTransactionsFailed(notification:)), name: PaymentQueue.RestoreCompletedTransactionsFailed, object: paymentQueue)
    }
    
    func subscriptionHasSinceExpired(claim: SubscriptionClaim?) -> Bool {
        guard let claim = claim, let jwt = try? JWT.jws(jwt: claim.value), let claims = try? Claims<SubscriptionClaim>.subscription(jwt: jwt) else {
            return false
        }
        
        return claims.hasExpired()
    }
    
    func purchaseSubscription(receiptData: String, completion: @escaping SubscriptionResource.TransactionsCompletion) {
        
        self.requestTransactions(receiptData: receiptData){ (account, claim, error) in
            
            /**
             This is the case where transactions for an expired subscription are sent for processing, in this case:
             
             * No need to notify. This is stale information and not neccesarily relevant at this thime.
             * No need to acquire a new authorisation token since it will be expired.
             
             - see: `Processing StoreKit transactions`, under considerations.md for a detailed scenario of this case.
            */
            if self.subscriptionHasSinceExpired(claim: claim) {
                return
            }

            switch error {
            case let error as AFError where error.isResponseValidationError:
                switch error.responseCode {
                case 403:
                    os_log("The receipt was invalid: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                default:
                    NotificationCenter.default.post(name: SubscriptionManager.SubscriptionFailed, object: self, userInfo: ["error": SubscriptionError.failed])
                }
            case let error as URLError:
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionFailed, object: self, userInfo: ["error": SubscriptionError.connectionError(error: error)])
            case .some(let error):
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionFailed, object: self, userInfo: ["error": error])
            case .none:
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionPurchased, object: self)
                break;
            }
            
            if let claim = claim, let account = account {
                self.requestSubscription(account: account, claim: claim) { token, error in
                    
                    switch error {
                    case let error as AFError where error.isResponseValidationError:
                        switch error.responseCode {
                        case 403:
                            os_log("The claim was invalid: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                        default:
                            NotificationCenter.default.post(name: SubscriptionManager.SubscriptionFailed, object: self, userInfo: ["error": SubscriptionError.failed])
                        }
                    case let error as URLError:
                        NotificationCenter.default.post(name: SubscriptionManager.SubscriptionFailed, object: self, userInfo: ["error": SubscriptionError.connectionError(error: error)])
                    case .some(let error):
                        NotificationCenter.default.post(name: SubscriptionManager.SubscriptionFailed, object: self, userInfo: ["error": error])
                    case .none:
                        completion(account, claim, error)
                        break
                    }
                }
            }
        }
    }
    
    /**
     
        In case the subscription in the receipt has expired,
            Posts a `SubscriptionManager.SubscriptionExpired` with a userInfo containing an `SubscriptionError.expired` under the "error" key.
     
     - Parameter receiptData: a base64 encoded string of the receipt data found under Bundle.main.appStoreReceiptURL
    */
    public func restoreSubscription(receiptData: String) {
        
        self.requestTransactions(receiptData: receiptData) { (account, claim, error) in
            
            switch error {
            case let error as AFError where error.isResponseValidationError:
                switch error.responseCode {
                case 403:
                    os_log("The receipt was invalid: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                default:
                    os_log("There was an unexpected error while restoring a subscription: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                    NotificationCenter.default.post(name: SubscriptionManager.SubscriptionRestoreFailed, object: self, userInfo: ["error": SubscriptionError.restoreFailed])
                }
            case let error as URLError:
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionRestoreFailed, object: self, userInfo: ["error": SubscriptionError.restoreConnectionError(error: error)])
            case .some(let error):
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionRestoreFailed, object: self, userInfo: ["error": error])
            case .none:                
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionRestored, object: self)
                break;
            }
            
            if let claim = claim, let account = account {
                
                guard let jwt = try? JWT.jws(jwt: claim.value), let claims = try? Claims<SubscriptionClaim>.subscription(jwt: jwt), !claims.hasExpired() else {
                    NotificationCenter.default.post(name: SubscriptionManager.SubscriptionExpired, object: self, userInfo: ["error": SubscriptionError.unauthorised(reason: .expired)])
                    return
                }
                
                self.requestSubscription(account: account, claim: claim) { token, error in
                    
                    switch error {
                    case let error as AFError where error.isResponseValidationError:
                        switch error.responseCode {
                        case 403:
                            os_log("The claim was invalid: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                        default:
                            NotificationCenter.default.post(name: SubscriptionManager.SubscriptionRestoreFailed, object: self, userInfo: ["error": SubscriptionError.failed])
                        }
                    case let subscriptionError as SubscriptionError where subscriptionError.isExpired:
                        NotificationCenter.default.post(name: SubscriptionManager.SubscriptionExpired, object: self, userInfo: ["error": subscriptionError])
                    case let error as URLError:
                        NotificationCenter.default.post(name: SubscriptionManager.SubscriptionRestoreFailed, object: self, userInfo: ["error": SubscriptionError.connectionError(error: error)])
                    case .some(let error):
                        NotificationCenter.default.post(name: SubscriptionManager.SubscriptionRestoreFailed, object: self, userInfo: ["error": error])
                    case .none:
                        break
                    }
                }
            }
        }
    }
    
    @discardableResult func products(productIdentifiers: [Product.Identifier] = [.individualMonthly]) -> SKProductsRequest {
        
        let productsRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers.compactMap{ $0.rawValue }))
        productsRequest.delegate = self
        productsRequest.start()
        
        self.productsRequest = productsRequest
        
        return productsRequest
    }
    
    @discardableResult func refreshReceipt() -> SKReceiptRefreshRequest {
        
        let receiptRefreshRequest = SKReceiptRefreshRequest()
        receiptRefreshRequest.delegate = self
        receiptRefreshRequest.start()
        
        self.receiptRefreshRequest = receiptRefreshRequest
        
        return receiptRefreshRequest
    }
    
    // MARK: SKRequestDelegate
    func requestDidFinish(_ request: SKRequest) {
        
        /*
            the delegate also receives a callback for the #products(productIdentifiers:) request.
            since the SKProductsRequest, on success, calls back on the #productsRequest(:didReceive:), this is done so as
            to avoid the double callback
        */
        guard request == self.receiptRefreshRequest else {
            return
        }
        
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            return
        }
        
        self.delegate?.success(self, receipt: appStoreReceiptURL)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.delegate?.error(self, didFailWithError: error)
    }
    
    // MARK: private
    @objc func transactionPurchasing(notification: NSNotification) {
        NotificationCenter.default.post(name: SubscriptionManager.SubscriptionPurchasing, object: self, userInfo: notification.userInfo)
    }
    
    @objc func transactionError(notification: NSNotification) {
        NotificationCenter.default.post(name: SubscriptionManager.SubscriptionFailed, object: self, userInfo: notification.userInfo)
    }
    
    @objc func restoreCompletedTransactionsFailed(notification: NSNotification) {
        NotificationCenter.default.post(name: SubscriptionManager.SubscriptionRestoreFailed, object: self, userInfo: notification.userInfo)
    }
    
    private func requestSubscription(account: Account, claim: SubscriptionClaim, completion: @escaping SubscriptionResource.SubscriptionCompletion = SubscriptionCompletionIgnore) {
        
        self.subscriptionResource.requestSubscription(account: account.identifier, claim: claim){ (token, error) in
            
            switch error {
            case .some(let error):
                completion(token, error)
            case .none:
                if let token = token?.value {
                    try? ApplicationStorage.default.write(value: token,
                                                          key: .subscriptionAuthorizationToken,
                                                          options: .completeFileProtectionUntilFirstUserAuthentication)
                }
                
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionActive, object: self)

                completion(token, error)
            }
        }
    }

    private func requestTransactions(receiptData: String, completion: @escaping SubscriptionResource.TransactionsCompletion) {
        
        self.subscriptionResource.requestTransactions(forReceipt: receiptData) { (account, claim, error) in
            
            switch error {
            case .some(let error):
                completion(account, claim, error)
            case .none:
                if let claim = claim?.value, let account = account?.identifier {
                    try? ApplicationStorage.default.write(value: claim,
                                                          key: .subscriptionClaim,
                                                          options: .completeFileProtectionUnlessOpen)
                    try? ApplicationStorage.default.write(value: account,
                                                          key: .account,
                                                          options: .completeFileProtectionUntilFirstUserAuthentication)
                }
                
                completion(account, claim, error)
            }
        }
    }
    
    // MARK: public
    public func startProcessingPayments() {
        self.paymentQueue.startObservingPaymentTransactions()
    }
    
    public func restoreSubscriptions() {
        self.paymentQueue.restoreCompletedTransactions()
    }
    
    public func purchase(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        self.paymentQueue.add(payment)
    }
    
    func listExports(forAccount account: String, completion: @escaping AccountResource.ExportsCompletion) {
        
        guard let authorizationToken = try? ApplicationStorage.default.read(key: .subscriptionAuthorizationToken) else { //just a reasonable fallback, shouldn't happen.
            os_log("The subscription authorization token appears to have been deleted. This is not according to spec. Should the spec had changed, remove this log.", log: .default, type: .error)
            let error = SubscriptionError.unauthorised(reason: .expired)
            NotificationCenter.default.post(name: SubscriptionManager.SubscriptionExpired, object: self, userInfo: ["error": error])
            completion(nil, error)
        return
        }
        
        //an invalid token will generate a different error message
        self.accountResource.requestExports(forAccount: account, authorizationToken: SubscriptionAuthorizationToken(value: authorizationToken) ) { (exports, error) in
         
            if case let error as SubscriptionError = error, error.isExpired {
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionExpired, object: self, userInfo: ["error": error])
                completion(nil, error)
            } else {
                completion(exports, error)
            }
        }.resume()
    }
}
