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
    
    let queue = DispatchQueue(label: "io.windmill.manager")
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        
        return URLSession(configuration: configuration)
    }()
    
    let sessionManager = SessionManager()
    
    @discardableResult func requestWindmills(forAccount account: String, completion: @escaping (_ windmills: [Windmill]?, _ error: Error?) -> Void) -> DataRequest {
        
        let url = "\(WINDMILL_BASE_URL)/account/\(account)/windmill"
        
        return sessionManager.request(url).responseData(queue: self.queue) { response in
            
            if case .failure(let error as AFError) = response.result, case let .responseSerializationFailed(reason) = error, case .inputDataNilOrZeroLength = reason {
                DispatchQueue.main.async{
                    completion([], nil)
                }
                return
            }
            
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
                let windmills = try decoder.decode([Windmill].self, from: data)
                
                DispatchQueue.main.async{
                    completion(windmills, nil)
                }
            } catch {
                DispatchQueue.main.async{
                    completion(nil, error)
                }
            }
        }
    }
    
    @discardableResult func requestRegisterDevice(forAccount account: String, withToken token: String, completion: @escaping (_ device: Device?, _ error: Error?) -> Void) -> DataRequest {
        
        let urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/account/\(account)/device/register", method: .post)
        
        let encodedURLRequest = try! URLEncoding.queryString.encode(urlRequest, with: ["token":token])
        
        return sessionManager.request(encodedURLRequest).responseString(completionHandler: { response in
            
            os_log("%{public}@", log: .default, type: .debug, String(describing: response.response))
            os_log("%{public}@", log: .default, type: .debug, String(describing: response.result.value ?? "Empty HTTP Response."))
            
        }).responseData(queue: self.queue) { response in
            
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
                completion(nil, error)
            }
        }
    }
}
