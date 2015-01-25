//
//  CafeteriaViewLabelTransformer.swift
//  Cafeteria
//
//  Created by Daniel Zoller on 25.01.15.
//  Copyright (c) 2015 nosebrain. All rights reserved.
//

import Foundation

@objc (CafeteriaViewLabelTransformer)
class CafeteriaViewLabelTransformer : NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject!) -> AnyObject? {
        if value == nil {
            return nil
        }
        
        if let cafeteria = value as? Cafeteria {
            return cafeteria.university! + " - " + cafeteria.name!
        }
        
        return nil;
    }
}