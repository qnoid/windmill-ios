//
//  ExportError.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 24/04/2019.
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

public enum ExportError : Error {
    
    case incompatible(target: String)
    case expired
    case elapsed
}

extension ExportError : CustomNSError, LocalizedError {
    
    public static var errorDomain: String {
        return "io.windmill.windmill"
    }
    
    public var errorTitle: String? {
        switch self {
        case .incompatible:
            return "Unsupported iOS"
        case .expired:
            return "Distribution Certificated Expired"
        case .elapsed:
            return "Access Elapsed"
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .incompatible(let target):
            return "This application requires iOS \(target) or later."
        case .expired:
            return "The distribution certificate used to export this application has expired.\n"
        case .elapsed:
            return "Access to this application has elapsed.\n"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .incompatible:
            return nil
        case .expired:
            return nil
        case .elapsed:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .incompatible(let target):
            return "You must update this device to iOS \(target) in order to download and use this application."
        case .expired:
            return "Use Windmill on the Mac to distribute the application with an up-to-date certificate."
        case .elapsed:
            return "You can choose to Refresh your list of applications for as long as your Subscription is still active."
        }
    }
    
    public var isDenied: Bool {
        switch self {
        case .elapsed:
            return true
        default:
            return false
        }
    }
}
