//
//  Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import Foundation

public struct Export: Codable {
    let id: UInt
    let identifier: String
    let version: Double
    let title: String
    let url: String
    let createdAt: Date
    let modifiedAt: Date    
}
