//
//  UIStoryboards.swift
//  windmill
//
//  Created by Markos Charatzas on 24/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

class Storyboards {
    
    static func main(bundle: Bundle = Bundle(for: Storyboards.self)) -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: bundle)
    }
    
    static func purchase(bundle: Bundle = Bundle(for: Storyboards.self)) -> UIStoryboard {
        return UIStoryboard(name: "Purchase", bundle: bundle)
    }
}
