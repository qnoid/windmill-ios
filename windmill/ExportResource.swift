//
//  ExportResource.swift
//  windmill
//
//  Created by Markos Charatzas on 02/05/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation
import os
import Alamofire


class ExportResource {
    
    typealias DeleteCompletion = (_ error: Error?) -> Void

    let queue = DispatchQueue(label: "io.windmill.windmill.manager")
    
    let sessionManager: SessionManager
    
    init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.sessionManager = SessionManager(configuration: configuration)
    }
    
    func requestDelete(export: Export, claim: SubscriptionClaim, completion: @escaping DeleteCompletion) -> DataRequest {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/export/\(export.identifier)", method: .delete)
        urlRequest.addValue("Bearer \(claim.value)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 10 //seconds
        
        return sessionManager.request(urlRequest).validate(statusCode: [204, 410]).responseData(queue: self.queue)  { response in
            
            switch response.result {
            case .failure(let error):
                switch error {
                case let error as AFError where error.isResponseValidationError:
                    switch (error.responseCode, response.data) {
                    case (401, let data?):
                        if let response = String(data: data, encoding: .utf8), let reason = SubscriptionError.UnauthorisationReason(rawValue: response) {
                            DispatchQueue.main.async{
                                completion(SubscriptionError.unauthorised(reason:reason))
                            }
                        } else {
                            DispatchQueue.main.async{
                                completion(SubscriptionError.unauthorised(reason: nil))
                            }
                        }
                    default:
                        DispatchQueue.main.async{
                            completion(error)
                        }
                    }
                default:
                    DispatchQueue.main.async{
                        completion(error)
                    }
                }
            case .success:
                DispatchQueue.main.async{
                    completion(nil)
                }
            }
        }
    }
}
