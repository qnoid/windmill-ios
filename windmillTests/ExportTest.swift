//
//  ExportTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 23/04/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import XCTest
@testable import windmill

class ExportTest: XCTestCase {


    func testGivenSameVersionAssertIsCompatibleTrue() {
        let inTen: Date = Date().addingTimeInterval(10)
        let metadata = Export.Metadata(configuration: .release, commit: Repository.Commit(branch: "master", shortSha: "95a9b91"), deployment: BuildSettings.Deployment( target: "12.0"), distributionSummary: DistributionSummary(certificateExpiryDate: inTen))
        
        XCTAssertTrue(metadata.targetsEqualOrLowerThan(version: "12.0"))
    }

    func testGivenSystemVersionIsLessAssertIsCompatibleFalse() {
        let inTen: Date = Date().addingTimeInterval(10)
        let metadata = Export.Metadata(configuration: .release, commit: Repository.Commit(branch: "master", shortSha: "95a9b91"), deployment: BuildSettings.Deployment( target: "12.0"), distributionSummary: DistributionSummary(certificateExpiryDate: inTen))

        XCTAssertFalse(metadata.targetsEqualOrLowerThan(version: "11.0"))
    }
    
    func testGivenSystemVersionIsGreaterAssertIsCompatibleTrue() {
        let inTen: Date = Date().addingTimeInterval(10)
        let metadata = Export.Metadata(configuration: .release, commit: Repository.Commit(branch: "master", shortSha: "95a9b91"), deployment: BuildSettings.Deployment( target: "11.0"), distributionSummary: DistributionSummary(certificateExpiryDate: inTen))

        XCTAssertTrue(metadata.targetsEqualOrLowerThan(version: "12.0"))
    }


}
