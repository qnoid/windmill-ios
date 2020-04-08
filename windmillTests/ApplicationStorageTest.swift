//
//  windmillTests.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 04/05/2016.
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

class EphemeralApplicationStorage {
    
    let key: ApplicationStorage.ApplicationStorageKey
    let applicationStorage: ApplicationStorage

    init(key: ApplicationStorage.ApplicationStorageKey, applicationStorage: ApplicationStorage = ApplicationStorage.default) {
        self.key = key
        self.applicationStorage = applicationStorage
    }
    
    func read() throws -> String {
        return try self.applicationStorage.read(key: self.key)
    }

    func write(value: String) throws {
        try self.applicationStorage.write(value: value, key: self.key)
    }

    deinit {
        try? self.applicationStorage.delete(key: self.key)
    }
}

class ApplicationStorageTest: XCTestCase {

    func testGivenValueAssertStored() {
        let applicationStorage = EphemeralApplicationStorage(key: ApplicationStorage.ApplicationStorageKey.account)
        
        let anyValue = "0F7DE374-00FB-46EC-8C48-F82D87E154FD"

        try! applicationStorage.write(value: anyValue)
        
        XCTAssertEqual(try? applicationStorage.read(), anyValue)
    }
}
