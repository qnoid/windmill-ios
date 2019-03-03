//
//  SubscriberStatus.swift
//  windmill
//
//  Created by Markos Charatzas on 19/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

enum SubscriptionStatus {

    static func make(account: String?, authorizationToken: String?) -> SubscriptionStatus? {
        
        guard let identifier = account else {
            return nil
        }
        
        if let authorizationToken = authorizationToken {
            return SubscriptionStatus(account: Account(identifier: identifier), authorizationToken: SubscriptionAuthorizationToken(value: authorizationToken))
        } else {
            return SubscriptionStatus(account: Account(identifier: identifier), authorizationToken: nil)
        }
    }
    
    static var `default`: SubscriptionStatus {
        let account = try? ApplicationStorage.default.read(key: .account)
        let authorizationToken = try? ApplicationStorage.default.read(key: .subscriptionAuthorizationToken)
        
        return make(account: account, authorizationToken: authorizationToken) ?? .none
    }

    case active(account: Account)
    case expired(account: Account)
    case none
    
    init?(account: Account?, authorizationToken: SubscriptionAuthorizationToken?){
        guard let account = account else {
            return nil
        }
        
        guard let authorizationToken = authorizationToken, let jwt = try? JWT.jws(jwt: authorizationToken.value), let claims = try? Claims<SubscriptionAuthorizationToken>.accessToken(jwt: jwt), !claims.hasExpired() else {
            self = .expired(account: account)
            return
        }
            
        self = .active(account: account)
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
