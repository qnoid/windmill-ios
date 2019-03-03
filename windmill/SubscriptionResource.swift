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
     
    
    typealias TransactionsCompletion = (_ account: Account?, _ claim: SubscriptionClaim?, _ error: Error?) -> Void
    
    typealias SubscriptionCompletion = (_ token: SubscriptionAuthorizationToken?, _ error: Error?) -> Void

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
        urlRequest.timeoutInterval = 10 //seconds
        return sessionManager.request(urlRequest).validate().responseData(queue: self.queue) { response in
            
            switch (response.result, response.data) {
                case (.failure, _):
                    DispatchQueue.main.async{
                        completion(nil, nil, response.error)
                    }
                case (.success, let data?):
                    let decoder = JSONDecoder()
                    
                    do {
                        let subscriptionClaim = try decoder.decode(SubscriptionClaim.self, from: data)
                        let account = try decoder.decode(Account.self, from: data)
                        
                        DispatchQueue.main.async{
                            completion(account, subscriptionClaim, nil)
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
    
    @discardableResult func requestSubscription(account: String, claim: SubscriptionClaim, completion: @escaping SubscriptionCompletion) -> DataRequest {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/subscription", method: .post)
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(claim.value)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = "{\"account_identifier\":\"\(account)\"}".data(using: .utf8)
        urlRequest.timeoutInterval = 10 //seconds
        
        return sessionManager.request(urlRequest).validate().responseData(queue: self.queue) { response in

            switch (response.result, response.result.value) {
            case (.failure(let error), _):
                switch error {
                case let error as AFError where error.isResponseValidationError:
                    switch (error.responseCode, response.data) {
                    case (401, let data?):
                        if let response = String(data: data, encoding: .utf8), let reason = SubscriptionError.UnauthorisationReason(rawValue: response) {
                            DispatchQueue.main.async{
                                completion(nil, SubscriptionError.unauthorised(reason:reason))
                            }
                        } else {
                            DispatchQueue.main.async{
                                completion(nil, SubscriptionError.unauthorised(reason: nil))
                            }
                        }
                    default:
                        DispatchQueue.main.async{
                            completion(nil, error)
                        }
                    }
                default:
                    DispatchQueue.main.async{
                        completion(nil, error)
                    }
                }
            case (.success, let data?):
                let decoder = JSONDecoder()
                
                do {
                    let subscriptionAuthorizationToken = try decoder.decode(SubscriptionAuthorizationToken.self, from: data)
                    
                    DispatchQueue.main.async{
                        completion(subscriptionAuthorizationToken, nil)
                    }
                } catch {
                    DispatchQueue.main.async{
                        completion(nil, error)
                    }
                }
                
                return
            default:
                DispatchQueue.main.async{
                    completion(nil, response.error)
                }
            }
        }
    }
}
