//
//  PaymentQueue.swift
//  windmill
//
//  Created by Markos Charatzas on 31/01/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation
import Alamofire
import StoreKit
import os

class PaymentQueue: NSObject, SKPaymentTransactionObserver {
    
    static let purchasing = Notification.Name("paymentQueue.transaction.purchasing")
    static let purchased = Notification.Name("paymentQueue.transaction.purchased")
    static let restored = Notification.Name("paymentQueue.transaction.restored")
    static let transactionError = Notification.Name("paymentQueue.transaction.error")
    static let restoreFailedWithError = Notification.Name("paymentQueue.transaction.restore.error")

    static let `default` = PaymentQueue()
    
    let queue = SKPaymentQueue.default()
    let subscriptionManager = SubscriptionManager()
    
    private override init() {
    
    }
    
    func add(_ payment: SKPayment) {
        self.queue.add(payment)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path), let rawReceiptData = try? Data(contentsOf: appStoreReceiptURL) else {
                    return
                }
                
                let receiptData = rawReceiptData.base64EncodedString()
                
                self.subscriptionManager.requestTransactions(receiptData: receiptData){ (account, token, error) in
                    
                    switch error {
                    case let error as AFError where error.isResponseValidationError:
                        switch error.responseCode {
                        case 403:
                            os_log("The receipt was invalid: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                        default:
                            os_log("There was an unexpected error while processing a transaction: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: PaymentQueue.transactionError, object: self, userInfo: ["error": WindmillError.subscriptionFailed])
                            }
                        }
                    case let error as URLError:
                        NotificationCenter.default.post(name: PaymentQueue.transactionError, object: self, userInfo: ["error": WindmillError.subscriptionConnectionError(error: error)])
                    case .some(let error):
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: PaymentQueue.transactionError, object: self, userInfo: ["error": error])
                        }
                    case .none:
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: PaymentQueue.purchased, object: self, userInfo: nil)
                        }
                        self.queue.finishTransaction(transaction)
                    }
                }
                
            case .purchasing:
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: PaymentQueue.purchasing, object: self, userInfo: nil)
                }
                return
            case .failed:

                // Only set if state is SKPaymentTransactionFailed
                guard let error = transaction.error else {
                    return
                }
                
                self.queue.finishTransaction(transaction)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: PaymentQueue.transactionError, object: self, userInfo: ["error": error])
                }
                return
            case .restored:
                self.queue.finishTransaction(transaction)
            case .deferred:
                return
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path), let rawReceiptData = try? Data(contentsOf: appStoreReceiptURL) else {
            return
        }
        
        let receiptData = rawReceiptData.base64EncodedString()
        
        self.subscriptionManager.requestTransactions(receiptData: receiptData){ (account, token, error) in
            switch error {
            case let error as AFError where error.isResponseValidationError:
                switch error.responseCode {
                case 403:
                    os_log("The receipt was invalid: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                default:
                    os_log("There was an unexpected error while restoring any completed transactions: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                    NotificationCenter.default.post(name: PaymentQueue.restoreFailedWithError, object: self, userInfo: ["error": WindmillError.restorePurchasesFailed])
                }
            case let error as URLError:
                NotificationCenter.default.post(name: PaymentQueue.restoreFailedWithError, object: self, userInfo: ["error": WindmillError.restorePurchasesConnectionError(error: error)])
            case .some(let error):
                NotificationCenter.default.post(name: PaymentQueue.restoreFailedWithError, object: self, userInfo: ["error": error])
            case .none:
                NotificationCenter.default.post(name: PaymentQueue.restored, object: self, userInfo: nil)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        NotificationCenter.default.post(name: PaymentQueue.restoreFailedWithError, object: self, userInfo: ["error": error])
    }
}
