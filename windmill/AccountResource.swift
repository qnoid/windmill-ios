//
//  AccountResource.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import Foundation
import os
import Alamofire

let WINDMILL_BASE_URL_PRODUCTION = "https://api.windmill.io"
let WINDMILL_BASE_URL_DEVELOPMENT = "http://192.168.1.2:8080"

#if DEBUG
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_DEVELOPMENT
#else
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_PRODUCTION
#endif

class AccountResource {
    
    typealias ExportsCompletion = (_ exports: [Export]?, _ error: Error?) -> Void
    
    let queue = DispatchQueue(label: "io.windmill.windmill.manager")
    
    let sessionManager: SessionManager
    
    init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.sessionManager = SessionManager(configuration: configuration)
    }
    
    func requestExports(forAccount account: Account, authorizationToken: SubscriptionAuthorizationToken, completion: @escaping ExportsCompletion) -> DataRequest {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/account/\(account.identifier)/exports", method: .get)
        urlRequest.addValue("Bearer \(authorizationToken.value)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 10 //seconds
        
        return sessionManager.request(urlRequest).validate().responseData(queue: self.queue) { response in
            
            switch (response.result, response.result.value) {
            case (.failure(let error), _):
                switch error {
                case let error as AFError where error.isResponseSerializationError: //case .inputDataNilOrZeroLength: = reason:
                    DispatchQueue.main.async{
                        completion([], nil)
                    }
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
                
                decoder.dateDecodingStrategy = .custom{ decoder -> Date in
                    let date = try decoder.singleValueContainer().decode(Double.self)
                    
                    return Date(timeIntervalSince1970: date)
                }
                
                do {
                    let exports = try decoder.decode([Export].self, from: data)
                    
                    DispatchQueue.main.async{
                        completion(exports, nil)
                    }
                } catch {
                    os_log("There was an unexpected error while parsing the list of exports: '%{public}@'", log: .default, type: .debug, error.localizedDescription)
                    DispatchQueue.main.async{
                        completion([], nil)
                    }
                }
            default:
                DispatchQueue.main.async{
                    completion(nil, response.error)
                }
            }
        }
    }
    
    @discardableResult func requestDevice(forAccount account: Account, withToken token: String, authorizationToken: SubscriptionAuthorizationToken, completion: @escaping (_ device: Device?, _ error: Error?) -> Void) -> DataRequest {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/account/\(account.identifier)/device", method: .post)
        urlRequest.addValue("Bearer \(authorizationToken.value)", forHTTPHeaderField: "Authorization")

        let encodedURLRequest = try! URLEncoding.queryString.encode(urlRequest, with: ["token":token])
        
        return sessionManager.request(encodedURLRequest).validate().responseData(queue: self.queue) { response in
            
            guard case .success = response.result, let data = response.data else {
                DispatchQueue.main.async{
                    completion(nil, response.error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            decoder.dateDecodingStrategy = .custom{ decoder -> Date in
                let date = try decoder.singleValueContainer().decode(Double.self)
                
                return Date(timeIntervalSince1970: date)
            }
            
            do {
                let device = try decoder.decode(Device.self, from: data)
                
                DispatchQueue.main.async{
                    completion(device, nil)
                }
            } catch {
                DispatchQueue.main.async{
                    completion(nil, error)
                }
            }
        }
    }
}
