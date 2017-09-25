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
let WINDMILL_BASE_URL_DEVELOPMENT = "http://192.168.1.26:8080"

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
        
        return sessionManager.request("\(WINDMILL_BASE_URL)/account/\(account)/windmill").responseJSON(queue: self.queue, options: .allowFragments) { response in
            
            if case .failure(let error as AFError) = response.result, case let .responseSerializationFailed(reason) = error, case .inputDataNilOrZeroLength = reason {
                DispatchQueue.main.async{
                    completion([], nil)
                }
                return
            }
            
            guard let array = response.result.value as? Array<Dictionary<String, AnyObject>> else {
                DispatchQueue.main.async{
                    completion(nil, response.result.error)
                }
            return
            }
            
            var windmills: [Windmill] = []
            for value in array {
                let id = value["id"]!.uintValue!
                let identifier = value["identifier"] as? String ?? ""
                let version = value["version"]!.doubleValue!
                let title = value["title"] as? String ?? ""
                let url = value["url"] as? String ?? ""
                let updatedAt = value["updatedAt"]!.doubleValue
                
                windmills.append(Windmill(id: id, identifier: identifier, version: version, title: title, url: url, updated_at: Date(timeIntervalSince1970: updatedAt!)))
            }
            
            DispatchQueue.main.async{
                completion(windmills, nil)
            }
        }
    }
    
    @discardableResult func requestRegisterDevice(forAccount account: String, withToken token: String, completion: @escaping (_ device: Device?, _ error: Error?) -> Void) -> DataRequest {
        
        let urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/account/\(account)/device/register", method: .post)
        
        let encodedURLRequest = try! URLEncoding.queryString.encode(urlRequest, with: ["token":token])
        
        return sessionManager.request(encodedURLRequest).responseString(completionHandler: { response in
            
            os_log("%{public}@", log: .default, type: .debug, String(describing: response.response))
            os_log("%{public}@", log: .default, type: .debug, String(describing: response.result.value ?? "Empty HTTP Response"))
            
        }).responseJSON(queue: self.queue, options: .allowFragments) { response in
            
            guard let dictionary = response.result.value as? Dictionary<String, AnyObject> else {
                DispatchQueue.main.async{
                    completion(nil, response.result.error)
                }
                return
            }
            
            let id = dictionary["id"]?.uintValue ?? 0
            let token = dictionary["token"] as? String ?? ""
            let createdAt = dictionary["createdAt"]?.doubleValue ?? 0.0
            let updatedAt = dictionary["updatedAt"]?.doubleValue ?? 0.0
            
            DispatchQueue.main.async{
                completion(Device(id: id, token: token, created_at:Date(timeIntervalSince1970: createdAt), updated_at: Date(timeIntervalSince1970: updatedAt)), nil)
            }
        }
    }
}
