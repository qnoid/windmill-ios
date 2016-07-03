//
//  AccountResource.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import Foundation

public class AccountResource {

    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    public func URLSessionTaskWindmills(forAccount account: String, completion:(windmills: [Windmill]?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let dataTask = self.session.dataTaskWithURL(NSURL(string: "http://api.windmill.io:8080/account/\(account)/windmill")!){ data, response, error in
            
            guard let data = data else {
                debugPrint(error)
                completion(windmills: nil, error: error)
            return
            }
            
            let json = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! Array<Dictionary<String, AnyObject>>
            
            debugPrint(json)
            
            if let error = error {
                dispatch_async(dispatch_get_main_queue()){
                    completion(windmills: nil, error: error)
                }
                return
            }
            
            var windmills: [Windmill] = []
            for value in json {
                let id = value["id"]!.integerValue
                let identifier = value["identifier"] as? String ?? ""
                let version = value["version"]!.doubleValue
                let title = value["title"] as? String ?? ""
                let url = value["url"] as? String ?? ""
                let updatedAt = value["updatedAt"]!.doubleValue
                
                windmills.append(Windmill(id: id, identifier: identifier, version: version, title: title, url: url, updated_at: NSDate(timeIntervalSince1970: updatedAt)))
            }
            
            dispatch_async(dispatch_get_main_queue()){
                completion(windmills: windmills, error: error)
            }
        }
        
        return dataTask
    }
}