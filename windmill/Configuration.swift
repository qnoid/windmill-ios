//
//  Configuration.swift
//  windmill
//
//  Created by Markos Charatzas on 24/04/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

public enum Configuration: String, Codable {
    case debug = "DEBUG"
    case release = "RELEASE"
    
    var name: String {
        switch self {
        case .debug:
            return "Debug"
        case .release:
            return "Release"
        }
    }
}
