//
//  WindmillApp.swift
//  windmill
//
//  Created by Markos Charatzas on 03/05/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

let WINDMILL_BASE_URL_PRODUCTION = "https://api.windmill.io"
let WINDMILL_BASE_URL_DEVELOPMENT = "http://192.168.1.2:8080"

#if DEBUG
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_DEVELOPMENT
#else
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_PRODUCTION
#endif

class WindmillApp {
    
    public static let ContentAvailable = Notification.Name("io.windmill.windmill.content-available")
    
    static let `default` = WindmillApp()
    
    private init() {
        
    }
    
    struct Storyboard {
        
        static func main(bundle: Bundle = Bundle(for: WindmillApp.self)) -> UIStoryboard {
            return UIStoryboard(name: "Main", bundle: bundle)
        }
        
        static func subscriber(bundle: Bundle = Bundle(for: WindmillApp.self)) -> UIStoryboard {
            return UIStoryboard(name: "Subscriber", bundle: bundle)
        }
        
        static func purchase(bundle: Bundle = Bundle(for: WindmillApp.self)) -> UIStoryboard {
            return UIStoryboard(name: "Purchase", bundle: bundle)
        }
        
        static func help(bundle: Bundle = Bundle(for: WindmillApp.self)) -> UIStoryboard {
            return UIStoryboard(name: "Help", bundle: bundle)
        }

    }
}
