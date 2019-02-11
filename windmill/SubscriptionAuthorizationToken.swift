//
//  SubscriptionAuthorizationToken.swift
//  windmill
//
//  Created by Markos Charatzas on 23/1/19.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

struct SubscriptionAuthorizationToken: Codable {
    
    enum CodingKeys: String, CodingKey {
        case value = "subscription_authorization_token"
    }

    let value: String;    
}
