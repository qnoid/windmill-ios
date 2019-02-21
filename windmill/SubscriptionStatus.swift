//
//  SubscriberStatus.swift
//  windmill
//
//  Created by Markos Charatzas on 19/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

enum SubscriptionStatus {
    
    static var shared: SubscriptionStatus {
        let account = try? ApplicationStorage.default.read(key: .account)
        let receiptClaim = try? ApplicationStorage.default.read(key: .receiptClaim)
        
        return SubscriptionStatus(account: account, receiptClaim: receiptClaim) ?? .none
    }
    
    case active
    case none
    
    init?(account: String?, receiptClaim: String?){
        guard case .some = account, case .some = receiptClaim else {
            return nil
        }
        
        self = .active
    }
    
    public var isActive: Bool {
        switch self {
        case .active:
            return true
        default:
            return false
        }
    }
}
