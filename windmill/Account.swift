//
//  Account.swift
//  windmill
//
//  Created by Markos Charatzas on 30/01/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

public struct Account: Codable {
    
    //Posted when the users purchases a new subscription
    static let isSubscriber = Notification.Name("account.isSubscriber")
    
    enum CodingKeys: String, CodingKey {
        case identifier = "account_identifier"
    }

    let identifier: String
}
