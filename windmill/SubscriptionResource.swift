//
//  SubscriptionResource.swift
//  windmill
//
//  Created by Markos Charatzas on 23/1/19.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation
import os
import Alamofire

class SubscriptionResource {
     
    
    typealias TransactionsCompletion = (_ account: Account?, _ receiptClaim: ReceiptClaim?, _ error: Error?) -> Void
    
    let queue = DispatchQueue(label: "io.windmill.manager")
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        
        return URLSession(configuration: configuration)
    }()
    
    let sessionManager = SessionManager()

    @discardableResult func requestTransactions(forReceipt receiptData: String, completion: @escaping TransactionsCompletion) -> DataRequest {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/subscription/transactions", method: .post)
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = "{\"data\":\"\(receiptData)\"}".data(using: .utf8)
        
        return sessionManager.request(urlRequest).validate().responseData(queue: self.queue) { response in
            
            switch (response.result, response.data) {
                case (.failure, _):
                    DispatchQueue.main.async{
                        completion(nil, nil, response.error)
                    }
                case (.success, let data?):
                    let decoder = JSONDecoder()
                    
                    do {
                        let receiptClaim = try decoder.decode(ReceiptClaim.self, from: data)
                        let account = try decoder.decode(Account.self, from: data)
                        
                        DispatchQueue.main.async{
                            completion(account, receiptClaim, nil)
                        }
                    } catch {
                        DispatchQueue.main.async{
                            completion(nil, nil, error)
                        }
                    }

                    return
                default:
                    DispatchQueue.main.async{
                        completion(nil, nil, response.error)
                    }
            }
        }
    }
}
