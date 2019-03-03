//
//  ClaimsTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 28/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
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
