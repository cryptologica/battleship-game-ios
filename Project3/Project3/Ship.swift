//
//  Ship.swift
//  Project3
//
//  Created by JT Newsome on 3/21/16.
//  Copyright © 2016 JT Newsome. All rights reserved.
//

import Foundation

class Ship: NSObject, NSCoding {
    
    var shipCoors: [Coordinate]?
    
    var count: Int {
        return shipCoors!.count
    }
    
    func getAtIndex(index: Int) -> Coordinate {
        return shipCoors![index]
    }
    
    init(shipCoors: [Coordinate]) {
        self.shipCoors = shipCoors
    }
    
    required init(coder decoder: NSCoder) {
        self.shipCoors = decoder.decodeObjectForKey("shipCoors") as? [Coordinate]
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(shipCoors, forKey: "shipCoors")
    }
    
    subscript(index: Int) -> Coordinate {
        return shipCoors![index]
    }
}
