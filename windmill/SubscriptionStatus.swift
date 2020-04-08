//
//  SubscriberStatus.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 19/02/2019.
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

/**
 The available stages in which a subscription status will progress, starting from the top
 
    .none       // No subscription exists yet on this device.
    .valid      // A subscription does exist and is the result of processed a valid receipt.
    .expired    // The subscription has expired. Using the associated account will result in a SubscriptionError.unauthorised(.expired)
    .active     // The subscription is currently active. The associated account can be used to access any of the services.
 */
enum SubscriptionStatus {

    static func make(account: String?, authorizationToken: String?) -> SubscriptionStatus? {
        
        guard let account = account else {
            return nil
        }
        
        guard let authorizationToken = authorizationToken, let jwt = try? JWT.jws(jwt: authorizationToken), let claims = try? Claims<SubscriptionAuthorizationToken>.accessToken(jwt: jwt), !claims.hasExpired() else {
            return nil
        }
        
        return SubscriptionStatus(account: Account(identifier: account), authorizationToken: SubscriptionAuthorizationToken(value: authorizationToken))
    }
    
    static func make(account: String?, claim: String?) -> SubscriptionStatus? {

        guard let account = account else {
            return nil
        }

        guard let claim = claim else {
            return nil
        }
        
        return SubscriptionStatus(account: Account(identifier: account), claim: SubscriptionClaim(value: claim))
    }

    static func make(claim: String?) -> SubscriptionStatus? {
        
        guard let claim = claim else {
            return nil
        }
        
        return SubscriptionStatus(claim: SubscriptionClaim(value: claim))
    }
    
    static var `default`: SubscriptionStatus {
        let claim = try? ApplicationStorage.default.read(key: .subscriptionClaim)
        let account = try? ApplicationStorage.default.read(key: .account)
        let authorizationToken = try? ApplicationStorage.default.read(key: .subscriptionAuthorizationToken)
        
        return make(account: account, authorizationToken: authorizationToken) ??
            make(account: account, claim: claim) ??
            make(claim: claim) ??
            .none
    }

    case active(account: Account, authorizationToken: SubscriptionAuthorizationToken)
    case expired(account: Account, claim: SubscriptionClaim)
    case valid(claim: SubscriptionClaim)
    case none
    
    init(claim: SubscriptionClaim){
        self = .valid(claim: claim)
    }

    init(account: Account, claim: SubscriptionClaim){
        self = .expired(account: account, claim: claim)
    }

    init?(account: Account, authorizationToken: SubscriptionAuthorizationToken){
        self = .active(account: account, authorizationToken: authorizationToken)
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
