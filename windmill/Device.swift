//
//  Device.swift
//  windmill
//
//  Created by Markos Charatzas on 06/07/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import Foundation

public struct Device: Codable, CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{token:\(token)}"
    }
    
    let id: UInt
    let token: String
    let createdAt: Date
}

