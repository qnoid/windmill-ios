//
//  Windmill.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 29/05/2016.
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

public struct Export: Codable {
    
    enum Status {
        case error(_ error: ExportError)
        case ok
    }
    
    public struct Metadata: Codable {
        
        enum CodingKeys: CodingKey {
            case commit
            case deployment
            case configuration
            case distributionSummary
            case applicationProperties
        }
        
        let configuration: Configuration
        let commit: Repository.Commit
        let deployment: BuildSettings.Deployment
        let distributionSummary: DistributionSummary
        let applicationProperties: ApplicationProperties
        
        func targetsEqualOrLowerThan(version: String) -> Bool {
            let targetsEqualOrLowerThan = version.compare(self.deployment.target, options: .numeric)
            return targetsEqualOrLowerThan == .orderedDescending || targetsEqualOrLowerThan == .orderedSame
        }
        
        func isExpired(date: Date = Date()) -> Bool {
            return self.distributionSummary.certificateExpiryDate < date
        }
    }
    
    public struct Manifest: Codable {
        let itms: String
        let elapsesAt: Date
        
        func isElapsed(date: Date = Date()) -> Bool {
            return self.elapsesAt < date
        }
    }

    
    let id: UInt
    let identifier: String
    let bundle: String
    let version: String
    let title: String
    let manifest: Manifest
    let createdAt: Date
    let modifiedAt: Date?
    let accessedAt: Date?
    
    let metadata: Metadata
    
    func targetsEqualOrLowerThan(version: String) -> Bool {
        return metadata.targetsEqualOrLowerThan(version: version)
    }
    
    var isExpired: Bool {
        return self.metadata.isExpired()
    }
    
    var isElapsed: Bool {
        return self.manifest.isElapsed()
    }
}
