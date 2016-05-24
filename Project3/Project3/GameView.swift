//
//  GameView.swift
//  Project3
//
//  Created by JT Newsome on 3/18/16.
//  Copyright © 2016 JT Newsome. All rights reserved.
//

import UIKit

class GameView: UIView {
    
    // Show user which ship size should be placed
    var shipBeingPlaced: UILabel?
    
    // Click to open attack board
    var toggleAttackBoardBtn: UIButton?
    
    // Length of side for each square on grid
    var cellEdgeLength: CGFloat = 0
    
    // Index in list of games (in lobby)
    var gameIndex: Int?
    
    var showAttackBoard = true
    
    // Gets currently placing player
    var currPlayer: Player! {
        // In placement phase?
        if (currentGame.player1?.hasPlaced == false) {
            return currentGame.player1!
        }
        else if (currentGame.player2?.hasPlaced == false) {
            return currentGame.player2!
        }
        // In play phase
        else {
            if (currentGame.player1?.isTurn == true) {
                return currentGame.player1
            }
            else {
                return currentGame.player2
            }
        }
    }
    
    // Gets currently placing player
    var myOpponent: Player! {
        if (currentGame.player1?.isTurn == true) {
            return currentGame.player2
        }
        else {
            return currentGame.player1
        }
    }
    
    // Coors for temp placement cells
    private var _placementCoors: [Coordinate] = []
    
    var placementCoors: [Coordinate] {
        get {
           return _placementCoors
        }
        set {
            _placementCoors = newValue
            setNeedsDisplay()
        }
    }
    
    // Game that is currently loaded
    private var _currentGame: Game = Game(player1: Player(isTurn: true), player2: Player(isTurn: false), isAddTile: false)
    
    var currentGame: Game {
        get {
            return _currentGame
        }
        set {
            _currentGame = newValue
            setNeedsDisplay()
        }
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.blueColor()
        
        shipBeingPlaced = UILabel(frame: CGRectMake(60, 475, 200, 25))
        shipBeingPlaced?.textColor = UIColor.whiteColor()
        addSubview(shipBeingPlaced!)
        
        toggleAttackBoardBtn = UIButton(frame: CGRectMake(50, 525, 200, 25))
        toggleAttackBoardBtn!.layer.backgroundColor = UIColor.whiteColor().CGColor
        toggleAttackBoardBtn!.setTitleColor(UIColor.blackColor(), forState: .Normal)
        toggleAttackBoardBtn!.layer.borderWidth = 1
        toggleAttackBoardBtn!.layer.cornerRadius = 8
        toggleAttackBoardBtn!.setTitle("Open SitRep Board", forState: .Normal)
        addSubview(toggleAttackBoardBtn!)
        
        print("Loaded: GameView")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        // MARK: RESET CELLS
        // Just redraw everything every time to ensure up-to-date
        var allCells: [Coordinate] = [Coordinate]()
        for var k: Int = 0; k < 10; k++ {
            for var l: Int = 0; l < 10; l++ {
                allCells.append(Coordinate(x: k, y: l))
            }
        }
        let colorSpace2 = CGColorSpaceCreateDeviceRGB()
        let components2: [CGFloat] = [0.0, 0.0, 0.0, 0.0] // Clear
        let backgroundColor2 = CGColorCreate(colorSpace2, components2)
        CGContextSetFillColorWithColor(context, backgroundColor2)
        for coor in allCells {
            let rect = getFillRectForCell(coor)
            CGContextFillRect(context, rect)
        }
        
        // MARK: DRAW GRID
        let viewWidth: CGFloat = self.bounds.width
        let viewHeight: CGFloat = self.bounds.height
        
        cellEdgeLength = min(viewHeight, viewWidth) / 10
        
        let x1: CGFloat = 0.0
        let y1: CGFloat = 115.0
        
        let x2: CGFloat = viewHeight
        let y2: CGFloat = cellEdgeLength * 10 + 115
        
        let lineWidth:CGFloat = 2.0
        CGContextSetLineWidth(context, lineWidth)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // [Red, Green, Blue, Alpha]
        var components: [CGFloat] = [1.0, 1.0, 1.0, 1.0] // White
        let lineColor = CGColorCreate(colorSpace, components)
        CGContextSetStrokeColorWithColor(context, lineColor)
        
        components = [0.0, 0.0, 1.0, 1.0] // Blue
        var backgroundColor = CGColorCreate(colorSpace, components)
        CGContextSetFillColorWithColor(context, backgroundColor)
        
        CGContextSetLineCap(context, .Butt)
        CGContextSetLineJoin(context, .Round)
        
        // Horizontal Lines
        var i: CGFloat = 115.0
        var numRows = 11
        repeat {
            
            CGContextMoveToPoint(context, x1, i)
            CGContextAddLineToPoint(context, x2, i)
            
            i = i + cellEdgeLength
            numRows--
            
        } while numRows > 0
        
        // Vertical Lines
        var j: CGFloat = 0.0
        repeat {
            
            CGContextMoveToPoint(context, cellEdgeLength + j, y1)
            CGContextAddLineToPoint(context, cellEdgeLength + j, y2)
            
            j = j + cellEdgeLength
            
        } while j < rect.width - cellEdgeLength
        
        CGContextStrokePath(context)
        
        // Play Phase
        if (currentGame.isPlayPhase == true) {
            
            // Attack Board
            if (showAttackBoard == true) {
                
                // Draw attacks that hit
                for coor in myOpponent!.hitCoordinates! {
                    let rect = getFillRectForCell(coor)
                    let circle = UIBezierPath(ovalInRect: rect)
                    UIColor.redColor().setFill()
                    circle.fill()
                }
                
                // Draw attacks that missed
                for coor in myOpponent!.missedCoordinates! {
                    let rect = getFillRectForCell(coor)
                    let circle = UIBezierPath(ovalInRect: rect)
                    UIColor.whiteColor().setFill()
                    circle.fill()
                }
            }
            // SitRep Board
            else {
                
                // Draw their ships
                components = [1.0, 1.0, 1.0, 1.0] // Black
                backgroundColor = CGColorCreate(colorSpace, components)
                CGContextSetFillColorWithColor(context, backgroundColor)
                for ship in currPlayer!.shipList! {
                    for var index=0; index < ship.count; index++ {
                        let coor = ship.getAtIndex(index)
                        let rect = getFillRectForCell(coor)
                        CGContextFillRect(context, rect)
                    }
                }
                
                // Draw misses
                for coor in currPlayer!.missedCoordinates! {
                    let rect = getFillRectForCell(coor)
                    let circle = UIBezierPath(ovalInRect: rect)
                    UIColor.whiteColor().setFill()
                    circle.fill()
                }
                
                // Draw hits
                for coor in currPlayer!.hitCoordinates! {
                    let rect = getFillRectForCell(coor)
                    let circle = UIBezierPath(ovalInRect: rect)
                    UIColor.redColor().setFill()
                    circle.fill()
                }
            }
        }
        // Placement Phase
        else {
            // Draw temporary ship cells
            components = [1.0, 1.0, 0.0, 1.0] // Yellow
            backgroundColor = CGColorCreate(colorSpace, components)
            CGContextSetFillColorWithColor(context, backgroundColor)
            for coor in placementCoors {
                let rect = getFillRectForCell(coor)
                CGContextFillRect(context, rect)
            }
            
            // Draw permanent ship cells
            components = [1.0, 1.0, 1.0, 1.0] // Black
            backgroundColor = CGColorCreate(colorSpace, components)
            CGContextSetFillColorWithColor(context, backgroundColor)
            // TODO: Determine which player we are drawing
            var count = 0
            for ship in currPlayer!.shipList! {
                for var index=0; index < ship.count; index++ {
                    let coor = ship.shipCoors![index]
                    print("x=\(coor.x) , y=\(coor.y) ShipAt[\(count)]CoorAt[\(index)]")
                    let rect = getFillRectForCell(coor)
                    CGContextFillRect(context, rect)
                }
                count++
            }
        }
    }
    
    func getFillRectForCell(cell: Coordinate) -> CGRect {
        return CGRectMake(CGFloat(cell.x) * cellEdgeLength, CGFloat(cell.y) * cellEdgeLength + 115, cellEdgeLength, cellEdgeLength)
    }
    
}