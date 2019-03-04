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
    
    let queue = DispatchQueue(label: "io.windmill.manager")
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        
        return URLSession(configuration: configuration)
    }()
    
    let sessionManager = SessionManager()
    
    func requestExports(forAccount account: String, authorizationToken: SubscriptionAuthorizationToken, completion: @escaping ExportsCompletion) -> DataRequest {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/account/\(account)/exports", method: .get)
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
                        completion(nil, response.error)
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
    
    @discardableResult func requestRegisterDevice(forAccount account: String, withToken token: String, completion: @escaping (_ device: Device?, _ error: Error?) -> Void) -> DataRequest {
        
        let urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/account/\(account)/device/register", method: .post)
        
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
