//
//  ClaimsTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 28/02/2019.
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

class ClaimsTest: XCTestCase {


    func testGivenAccessTokenClaimsAssertValues() {
        let value = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIxNkZBVXpSQlZKYkFmc0lSdlZSV25RIiwic3ViIjoiMTAwMDAwMDQ5NzkzMTk5MyIsImV4cCI6MTU1MDkwMzM3OSwidHlwIjoiYXQiLCJ2IjoxfQ.fYV2Cb5V96KDrV_WTIpl8_yZ_YueyeBgZUDUuo-W7D0"
        
        let jwt = try! JWT.jws(jwt: value)
        let accessToken = try! Claims<SubscriptionAuthorizationToken>.accessToken(jwt: jwt)
        
        XCTAssertNotNil(accessToken)
        XCTAssertEqual("16FAUzRBVJbAfsIRvVRWnQ", accessToken.jti)
        XCTAssertEqual("1000000497931993", accessToken.sub)
        XCTAssertEqual(Date(timeIntervalSince1970: 1550903379), accessToken.exp)
        XCTAssertEqual(ClaimsType.access_token, accessToken.typ)
        XCTAssertEqual(1, accessToken.v)
    }
    
    func testGivenExpiredAccessTokenClaimsAssertHasExpired() {
        let claims = Claims<SubscriptionAuthorizationToken>()
        claims.exp = Date.distantPast
        
        XCTAssertTrue(claims.hasExpired())
    }
    
    func testGivenValidAccessTokenClaimsAssertHasNotExpired() {
        let claims = Claims<SubscriptionAuthorizationToken>()
        claims.exp = Date.distantFuture
        
        XCTAssertFalse(claims.hasExpired())
    }

}
