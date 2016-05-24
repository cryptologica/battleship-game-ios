//
//  Coordinate.swift
//  Project3
//
//  Created by JT Newsome on 3/20/16.
//  Copyright © 2016 JT Newsome. All rights reserved.
//

import Foundation

class Coordinate: NSObject, NSCoding {
    
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    required init(coder decoder: NSCoder) {
        self.x = decoder.decodeIntegerForKey("x")
        self.y = decoder.decodeIntegerForKey("y")
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeInteger(self.x, forKey: "x")
        coder.encodeInteger(self.y, forKey: "y")
    }
}