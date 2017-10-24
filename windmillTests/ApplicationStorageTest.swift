//
//  windmillTests.swift
//  windmillTests
//
//  Created by Markos Charatzas on 04/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import XCTest
@testable import windmill

class EphemeralApplicationStorage {
    
    let key: String
    let applicationStorage: ApplicationStorage

    init(key: String, applicationStorage: ApplicationStorage = ApplicationStorage.default) {
        self.key = key
        self.applicationStorage = applicationStorage
    }
    
    func read() throws -> String {
        return try self.applicationStorage.read(key: self.key)
    }

    func write(value: Data) throws {
        try self.applicationStorage.write(value: value, key: self.key)
    }

    deinit {
        try? self.applicationStorage.delete(key: self.key)
    }
}

class ApplicationStorageTest: XCTestCase {

    func testGivenValueAssertStored() {
        let applicationStorage = EphemeralApplicationStorage(key: "any")
        
        let anyValue = "0F7DE374-00FB-46EC-8C48-F82D87E154FD"

        try! applicationStorage.write(value: anyValue.data(using: .utf8)!)
        
        XCTAssertEqual(try? applicationStorage.read(), anyValue)
    }
}
