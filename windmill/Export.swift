//
//  Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
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

    
    let id: UInt
    let identifier: String
    let bundle: String
    let version: String
    let title: String
    let url: String
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
}
