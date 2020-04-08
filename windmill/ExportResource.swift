//
//  ExportResource.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 02/05/2019.
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
