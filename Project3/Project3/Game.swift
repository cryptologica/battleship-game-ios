//
//  Game.swift
//  Project3
//
//  Created by JT Newsome on 3/19/16.
//  Copyright © 2016 JT Newsome. All rights reserved.
//

import Foundation

class Game: NSObject, NSCoding {
    
    var player1: Player?
    var player2: Player?
    var isAddTile: Bool
    var placementIndex: Int
    var placeShips: [Int] = [5, 4, 3, 2, 1]
    
    var isPlayPhase: Bool {
        return (player1?.hasPlaced == true && player2?.hasPlaced == true)
    }
    
    // Empty string if no winner yet
    var getWinner: String {
        if (player1?.numShipsAlive == 0) {
            return "Player 2"
        }
        else if (player2?.numShipsAlive == 0) {
            return "Player 1"
        }
        else {
            return ""
        }
    }
    
    init(player1: Player, player2: Player, isAddTile: Bool) {
        self.player1 = player1
        self.player2 = player2
        self.isAddTile = isAddTile
        self.placementIndex = 0
    }

    required init(coder decoder: NSCoder) {
        self.player1 = decoder.decodeObjectForKey("player1") as? Player
        self.player2 = decoder.decodeObjectForKey("player2") as? Player
        self.isAddTile = decoder.decodeBoolForKey("isAddTile")
        self.placementIndex = decoder.decodeIntegerForKey("placementIndex")
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.player1, forKey: "player1")
        coder.encodeObject(self.player2, forKey: "player2")
        coder.encodeBool(self.isAddTile, forKey: "isAddTile")
        coder.encodeInteger(self.placementIndex, forKey: "placementIndex")
    }
    
}