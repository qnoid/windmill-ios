//
//  Repository.swift
//  windmill
//
//  Created by Markos Charatzas on 27/04/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

public struct Repository {
    
    public struct Commit: Codable {
        let branch: String
        let shortSha: String
    }
}
