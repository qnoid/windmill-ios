//
//  BuildSettings.swift
//  windmill
//
//  Created by Markos Charatzas on 27/04/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

public class BuildSettings {
    
    public struct Deployment: Codable {
        let target: String
    }
}
