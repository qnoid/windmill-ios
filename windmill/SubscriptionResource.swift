//
//  SubscriptionResource.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 23/1/19.
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

import Foundation
import os
import Alamofire

class SubscriptionResource {
     
    
    typealias TransactionsCompletion = (_ claim: SubscriptionClaim?, _ error: Error?) -> Void
    
    typealias SubscriptionCompletion = (_ account: Account?, _ token: SubscriptionAuthorizationToken?, _ error: Error?) -> Void

    let queue = DispatchQueue(label: "io.windmill.windmill.manager")
    
    let sessionManager: SessionManager
    
    init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.sessionManager = SessionManager(configuration: configuration)
    }

    @discardableResult func requestTransactions(forReceipt receiptData: String, completion: @escaping TransactionsCompletion) -> DataRequest {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/subscription/transactions", method: .post)
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = "{\"data\":\"\(receiptData)\"}".data(using: .utf8)
        urlRequest.timeoutInterval = 30 //seconds
        return sessionManager.request(urlRequest).validate().responseData(queue: self.queue) { response in
            
            switch (response.result, response.data) {
                case (.failure, _):
                    DispatchQueue.main.async{
                        completion(nil, response.error)
                    }
                case (.success, let data?):
                    switch (response.response?.statusCode) {
                        case 200, 201:
                            let decoder = JSONDecoder()
                            
                            do {
                                let subscriptionClaim = try decoder.decode(SubscriptionClaim.self, from: data)
                                
                                DispatchQueue.main.async{
                                    completion(subscriptionClaim, nil)
                                }
                            } catch {
                                DispatchQueue.main.async{
                                    completion(nil, error)
                                }
                            }
                        case 202:
                            DispatchQueue.main.async{
                                completion(nil, SubscriptionError.outdated)
                            }
                        case 204:
                            DispatchQueue.main.async{
                                completion(nil, SubscriptionError.expired)
                            }
                    default:
                        break
                }
                default:
                    DispatchQueue.main.async{
                        completion(nil, response.error)
                    }
            }
        }
    }
    
    @discardableResult func requestSubscription(user: String, container: String, claim: SubscriptionClaim, completion: @escaping SubscriptionCompletion) -> DataRequest {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/subscription", method: .post)
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(claim.value)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = "{\"user_identifier\":\"\(user)\", \"user_container\":\"\(container)\"}".data(using: .utf8)
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
                                completion(nil, nil, SubscriptionError.unauthorised(reason:reason))
                            }
                        } else {
                            DispatchQueue.main.async{
                                completion(nil, nil, SubscriptionError.unauthorised(reason: nil))
                            }
                        }
                    default:
                        DispatchQueue.main.async{
                            completion(nil, nil, error)
                        }
                    }
                default:
                    DispatchQueue.main.async{
                        completion(nil, nil, error)
                    }
                }
            case (.success, let data?):
                let decoder = JSONDecoder()
                
                do {
                    let account = try decoder.decode(Account.self, from: data)
                    let subscriptionAuthorizationToken = try decoder.decode(SubscriptionAuthorizationToken.self, from: data)
                    
                    DispatchQueue.main.async{
                        completion(account, subscriptionAuthorizationToken, nil)
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
