//
//  ExportTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 23/04/2019.
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

import XCTest
@testable import windmill

class ExportTest: XCTestCase {


    func testGivenSameVersionAssertIsCompatibleTrue() {
        let inTen: Date = Date().addingTimeInterval(10)
        let metadata = Export.Metadata(configuration: .release, commit: Repository.Commit(branch: "master", shortSha: "95a9b91", date: Date()), deployment: BuildSettings.Deployment( target: "12.0"), distributionSummary: DistributionSummary(certificateExpiryDate: inTen), applicationProperties: ApplicationProperties(bundleDisplayName: "1.0", bundleVersion: "1.0"))
        
        XCTAssertTrue(metadata.targetsEqualOrLowerThan(version: "12.0"))
    }

    func testGivenSystemVersionIsLessAssertIsCompatibleFalse() {
        let inTen: Date = Date().addingTimeInterval(10)
        let metadata = Export.Metadata(configuration: .release, commit: Repository.Commit(branch: "master", shortSha: "95a9b91", date: Date()), deployment: BuildSettings.Deployment( target: "12.0"), distributionSummary: DistributionSummary(certificateExpiryDate: inTen), applicationProperties: ApplicationProperties(bundleDisplayName: "1.0", bundleVersion: "1.0"))
        
        XCTAssertFalse(metadata.targetsEqualOrLowerThan(version: "11.0"))
    }
    
    func testGivenSystemVersionIsGreaterAssertIsCompatibleTrue() {
        let inTen: Date = Date().addingTimeInterval(10)
        let metadata = Export.Metadata(configuration: .release, commit: Repository.Commit(branch: "master", shortSha: "95a9b91", date: Date()), deployment: BuildSettings.Deployment( target: "11.0"), distributionSummary: DistributionSummary(certificateExpiryDate: inTen), applicationProperties: ApplicationProperties(bundleDisplayName: "1.0", bundleVersion: "1.0"))
        
        XCTAssertTrue(metadata.targetsEqualOrLowerThan(version: "12.0"))
    }


}
