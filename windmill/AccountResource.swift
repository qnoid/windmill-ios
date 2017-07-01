//
//  AccountResource.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import Foundation

let WINDMILL_BASE_URL_PRODUCTION = "http://api.windmill.io:8080"
let WINDMILL_BASE_URL_DEVELOPMENT = "http://10.0.1.15:8080"

#if DEBUG
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_DEVELOPMENT
#else
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_PRODUCTION
#endif

extension URLSession {
    
    func windmill_jsonTaskWithURL(_ url: URL, completionHandler: @escaping (_ json: Any?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        return self.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                debugPrint(error ?? "")
                completionHandler(nil, error)
                return
            }
            
            debugPrint(json)
            completionHandler(json, error)
        })
    }
}

open class AccountResource {

    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        
        return URLSession(configuration: configuration)
    }()
    
    open func URLSessionTaskWindmills(forAccount account: String, completion: @escaping (_ windmills: [Windmill]?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        return self.session.windmill_jsonTaskWithURL(URL(string: "\(WINDMILL_BASE_URL)/account/\(account)/windmill")!){ json, error in
            
            guard let array = json as? Array<Dictionary<String, AnyObject>> else {
                DispatchQueue.main.async{
                    completion(nil, error)
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
                completion(windmills, error)
            }
        }
    }
}
