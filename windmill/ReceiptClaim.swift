//
//  ClaimAuthorizationToken.swift
//  windmill
//
//  Created by Markos Charatzas on 02/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

struct ReceiptClaim: Codable {
    
    enum CodingKeys: String, CodingKey {
        case value = "claim"
    }
    
    let value: String;
}
