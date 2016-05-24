//
//  GameViewController.swift
//  Project3
//
//  Created by JT Newsome on 3/18/16.
//  Copyright © 2016 JT Newsome. All rights reserved.
//

import UIKit

protocol LobbyViewControllerDelegate: class {
    
    func sendDataToLobbyView(sender: GameViewController, game: Game, gameIndex: Int)
}

class GameViewController: UIViewController, GameViewControllerDelegate {
    
    weak var delegate: LobbyViewControllerDelegate? = nil
    
    var parent: LobbyViewController?
    
    private var gameView: GameView! {
        return (view as! GameView)
    }
    
    override func loadView() {
        view = GameView(frame: CGRectZero)
        print("Loaded: GameViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Game"
        
        gameView.toggleAttackBoardBtn?.hidden = true
        gameView.toggleAttackBoardBtn?.addTarget(self, action: "toggleAttackBoardBtnClicked", forControlEvents: .TouchDown)
    }
    
    override func viewDidAppear(anim: Bool) {
        
        // Game already over?
        let name = gameView.currentGame.getWinner
        if (name != "") {
            displayConfirmDialog("Confirm", message: "\(name) Won!")
        }
        // Check if placement is done
        if (gameView.currentGame.isPlayPhase == false) {
            
            gameView.shipBeingPlaced!.text = "Place Ship of Size: \(gameView.currentGame.placeShips[gameView.currentGame.placementIndex])"
            gameView.toggleAttackBoardBtn?.hidden = true
            
            if (gameView.currentGame.player1?.hasPlaced == false) {
                // Confirm: Player 1 Place Ships
                displayConfirmDialog("Confirm", message: "Player 1's turn to place their ships.    (Tap to select/deselect cells)")
            }
            else {
                // Confirm: Player 2 Place Ships
                displayConfirmDialog("Confirm", message: "Player 2's turn to place their ships.    (Tap to select/deselect cells)")
            }
        }
        // Play Phase
        else {
            gameView.showAttackBoard = true
            gameView.toggleAttackBoardBtn?.hidden = false
            gameView.shipBeingPlaced!.text = "Choose A Cell to Attack"
            gameView.toggleAttackBoardBtn?.setTitle("Open SitRep Board", forState: .Normal)
        }
        gameView.setNeedsDisplay()
    }
    
    // Gets called when Lobby sends us selected Game
    func sendDataToGameView(sender: LobbyViewController, game: Game, gameIndex: Int) {
        print("Game View: Received Data From Lobby")
        parent = sender
        gameView.currentGame = game
        gameView.gameIndex = gameIndex
        gameView.currentGame.placementIndex = game.placementIndex
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(gameView)
        let cellCoordinate: Coordinate = getCellCoordinate(touchPoint)
        
        print("Cell Touched: (\(touchPoint.x), \(touchPoint.y))")
        print("Activate Cell: (\(cellCoordinate.x), \(cellCoordinate.y))")
        
        // Game over? Don't do anything
        if (gameView.currentGame.getWinner != "") {
            return
        }
        
        // Don't do anything unless click was inside grid
        if (isValidTouch(touchPoint) == true) {
            print("Valid Cell Touched")

            // Play Phase
            if (gameView.currentGame.isPlayPhase == true) {
                // Must be on Attack Board to attack
                if (gameView.showAttackBoard == true) {
                    // Must be empty
                    if (checkCellIsEmpty(cellCoordinate)) {
                        var title = ""
                        let message = ""
                        
                        // Was a Hit
                        if (containsCoordinate(gameView.myOpponent.shipList!, c: cellCoordinate) >= 0) {
                            
                            if (willSinkShip(cellCoordinate) == true) {
                                title = "Hit and Sunk!"
                                gameView.myOpponent.numShipsAlive--
                            }
                            else {
                                title = "Hit!"
                            }
                            
                            // Add so it can be drawn
                            gameView.myOpponent.hitCoordinates?.append(cellCoordinate)
                            
                        }
                        // Miss
                        else {
                            title = "Missed!"
                            gameView.myOpponent.missedCoordinates?.append(cellCoordinate)
                        }
                        
                        // Update lobby and save
                        sendDataToGameView(parent!, game: gameView.currentGame, gameIndex: gameView.gameIndex!)
                        
                        // Display alert saying hit/hit&sunk/miss
                        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                            // Callback: Upon confirming, switch players / display win and exit
                            var message: String
                            if (self.didWin() == true) {
                                message = "You won!"
                                let refreshAlert = UIAlertController(title: "Game Over", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                                    // Callback: Upon confirming, exit
                                    self.navigationController?.popViewControllerAnimated(true)
                                    // Assuming pop causes exit, but just to be sure
                                    return
                                }))
                                let subview = refreshAlert.view.subviews.first! as UIView
                                let alertContentView = subview.subviews.first! as UIView
                                alertContentView.backgroundColor = UIColor.whiteColor()
                                alertContentView.tintColor = UIColor.darkGrayColor()
                                self.presentViewController(refreshAlert, animated: true, completion: nil)
                            }
                            if (self.gameView.currentGame.player1?.isTurn == true) {
                                message = "Player 2's Turn"
                                self.gameView.currentGame.player1?.isTurn = false
                                self.gameView.currentGame.player2?.isTurn = true
                            }
                            else {
                                message = "Player 1's Turn"
                                self.gameView.currentGame.player1?.isTurn = true
                                self.gameView.currentGame.player2?.isTurn = false
                            }
                            self.displaySwitchPlayerView(message)
                        }))
                        let subview = refreshAlert.view.subviews.first! as UIView
                        let alertContentView = subview.subviews.first! as UIView
                        alertContentView.backgroundColor = UIColor.whiteColor()
                        alertContentView.tintColor = UIColor.darkGrayColor()
                        presentViewController(refreshAlert, animated: true, completion: nil)
                    }
                }
            }
            
            let cellList = gameView.placementCoors
            let lastCell = gameView.placementCoors.last
            
            // Check not a cell that's already filled
            var index: Int = containsCoordinate(gameView.currPlayer.shipList!, c: cellCoordinate)
            if (index >= 0) {
                return
            }
            
            // Check if deselecting
            index = containsTempCoordinate(gameView.placementCoors, c: cellCoordinate)
            if (index >= 0) {
                // Only remove if it's the cell that was most recently added
                if (lastCell!.x == cellCoordinate.x && lastCell!.y == cellCoordinate.y) {
                    gameView.placementCoors.removeAtIndex(index)
                    return
                }
                return
            }
            
            // Check is adjacent cell (horiz/vert placement only)
            if (lastCell != nil && isPlacementAddValid(cellList, currCell: cellCoordinate) == false) {
                return
            }
                
            // Add to temp coors to be drawn
            gameView.placementCoors.append(cellCoordinate)
            
            // Check if a full ship was placed
            if (gameView.currentGame.placeShips[gameView.currentGame.placementIndex] == gameView.placementCoors.count) {
                
                // Save into permanent ship coors
                let newShip: Ship = Ship(shipCoors: gameView.placementCoors)
                gameView.currPlayer.shipList?.append(newShip)
                
                // Clear temp coors
                gameView.placementCoors.removeAll()
                
                // Send updated data to Lobby to be saved
                self.delegate = self.parent
                print("Sending Data to Lobby...")
                delegate?.sendDataToLobbyView(self, game: gameView.currentGame, gameIndex: gameView.gameIndex!)
                
                // Was that their last ship?
                if (gameView.currentGame.placementIndex == gameView.currentGame.placeShips.count - 1) {
                    
                    // Reset Placement Index
                    gameView.currentGame.placementIndex = 0
                    
                    // Player 2 already placed -> Play Phase
                    if (gameView.currentGame.player2?.hasPlaced == true) {
                        gameView.shipBeingPlaced!.text = "Choose A Cell to Attack"
                        displaySwitchPlayerView("Player 1's Turn")
                    }
                    // Player 2 needs to place first
                    else {
                        // Update label
                        gameView.shipBeingPlaced!.text = "Place Ship of Size: \(gameView.currentGame.placeShips[gameView.currentGame.placementIndex])"
                        
                        displayConfirmDialog("Confirm", message: "Player 2's turn to place their ships.    (Tap to select/deselect cells)")
                    }
                }
                // Still more ships to place
                else {
                    // Go to next ship
                    gameView.currentGame.placementIndex++
                    print("placementIndex = \(gameView.currentGame.placementIndex)")
                    
                    // Update label
                    gameView.shipBeingPlaced!.text = "Place Ship of Size: \(gameView.currentGame.placeShips[gameView.currentGame.placementIndex])"
                }
            }
        }
    }
    
    // MARK: Helper Methods
    
    // Black view to prevent "cheating".
    // Pass the player name of who you're switching to.
    // Pops back to this view when confirms.
    func displaySwitchPlayerView(message: String) {
        gameView.setNeedsDisplay()
        let switchPlayerVC = SwitchPlayerViewController()
        switchPlayerVC.message = message
        navigationController?.pushViewController(switchPlayerVC, animated: true)
    }
    
    // Display a prompt with the given title and message
    func displayConfirmDialog(title: String, message: String) {
        sendDataToGameView(parent!, game: gameView.currentGame, gameIndex: gameView.gameIndex!)
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            self.gameView.setNeedsDisplay()
        }))
        let subview = refreshAlert.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        alertContentView.backgroundColor = UIColor.whiteColor()
        alertContentView.tintColor = UIColor.darkGrayColor()
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func toggleAttackBoardBtnClicked() {
        if (gameView.showAttackBoard == true) {
            gameView.toggleAttackBoardBtn?.setTitle("Open Attack Board", forState: .Normal)
            gameView.showAttackBoard = false
            gameView.shipBeingPlaced?.hidden = true
            gameView.setNeedsDisplay()
        }
        else {
            gameView.toggleAttackBoardBtn?.setTitle("Open SitRep Board", forState: .Normal)
            gameView.showAttackBoard = true
            gameView.setNeedsDisplay()
            gameView.shipBeingPlaced?.hidden = false
        }
    }
    
    func didWin() -> Bool {
        if (gameView.myOpponent.numShipsAlive == 0) {
            return true
        }
        else {
            return false
        }
    }
    
    func willSinkShip(cell: Coordinate) -> Bool {
        // Find the ship that coordinate is in
        let arr = gameView.myOpponent.shipList
        var shipIndex: Int
        for shipIndex = 0; shipIndex < arr!.count; shipIndex++ {
            let ship: Ship = arr![shipIndex]
            for var index = 0; index < ship.count; index++ {
                let coor: Coordinate = ship.getAtIndex(index)
                // Found which ship
                if (coor.x == cell.x && coor.y == cell.y) {
                    // Calculate how many cells aren't already hit on that ship
                    var count = 0
                    let ship = gameView.myOpponent.shipList![shipIndex]
                    for var index=0; index < ship.count; index++ {
                        if ((containsTempCoordinate(gameView.myOpponent.hitCoordinates!, c: ship[index]) >= 0) == true) {
                            count++
                        }
                    }
                    count = gameView.myOpponent.shipList![shipIndex].count - count
                    // If there's only 1 un-hit cell on that ship then it will sink
                    if (count == 1) {
                        return true
                    }
                    else {
                        return false
                    }
                }
            }
        }
        return false
    }
    
    // Checks that ships are placed vert/horiz only
    // Pass in the last cell that was placed and the to-be-placed cell
    func isPlacementAddValid(addedCells: [Coordinate], currCell: Coordinate) -> Bool {
        var validCells: [Coordinate] = [Coordinate]()
        
        // Ambiguous If Vert or Horiz
        if (addedCells.count == 1) {
            let lastCell: Coordinate = addedCells[0]
            validCells.append(Coordinate(x: lastCell.x + 1, y: lastCell.y))
            validCells.append(Coordinate(x: lastCell.x - 1, y: lastCell.y))
            validCells.append(Coordinate(x: lastCell.x, y: lastCell.y + 1))
            validCells.append(Coordinate(x: lastCell.x, y: lastCell.y - 1))
        }
        else if (addedCells.count > 1) {
            let firstCell: Coordinate = addedCells[0]
            let nextCell: Coordinate = addedCells[1]
            
            // Is Horizontal
            if (firstCell.x - nextCell.x != 0) {
                var minXCell: Coordinate = firstCell
                var maxXCell: Coordinate = firstCell
                for cell in addedCells {
                    if (cell.x < minXCell.x) {
                        minXCell = cell
                    }
                    if (cell.x > maxXCell.x) {
                        maxXCell = cell
                    }
                }
                validCells.append(Coordinate(x: minXCell.x - 1, y: minXCell.y))
                validCells.append(Coordinate(x: maxXCell.x + 1, y: maxXCell.y))
            }
            // Is Vertical
            else {
                var minYCell: Coordinate = firstCell
                var maxYCell: Coordinate = firstCell
                for cell in addedCells {
                    if (cell.y < minYCell.y) {
                        minYCell = cell
                    }
                    if (cell.y > maxYCell.y) {
                        maxYCell = cell
                    }
                }
                validCells.append(Coordinate(x: minYCell.x, y: minYCell.y - 1))
                validCells.append(Coordinate(x: maxYCell.x, y: maxYCell.y + 1))
            }
        }
        
        if (containsTempCoordinate(validCells, c: currCell) >= 0) {
            return true
        }
        else {
            return false
        }
    }
    
    func checkCellIsEmpty(cell: Coordinate) -> Bool {
        let isMiss = (containsTempCoordinate(gameView.myOpponent.missedCoordinates!, c: cell) >= 0)
        let isHit = (containsTempCoordinate(gameView.myOpponent.hitCoordinates!, c: cell) >= 0)
        if (isMiss == false && isHit == false) {
            return true
        }
        return false
    }
    
    // Returns index if the array contains given coordinate
    // Returns -1 if it does not contain it
    func containsCoordinate(arr: [Ship], c: Coordinate) -> Int {
        
        for var shipIndex = 0; shipIndex < arr.count; shipIndex++ {
            let ship: Ship = arr[shipIndex] as Ship
            for var index = 0; index < ship.count; index++ {
                let coor: Coordinate = ship.getAtIndex(index)
                if (coor.x == c.x && coor.y == c.y) {
                    return index
                }
            }
        }
        return -1
    }
    
    func containsTempCoordinate(coors: [Coordinate], c: Coordinate) -> Int {
        for var index = 0; index < coors.count; index++ {
            let coor: Coordinate = coors[index]
            if (coor.x == c.x && coor.y == c.y) {
                return index
            }
        }
        return -1
    }
    
    func getCellCoordinate(point: CGPoint) -> Coordinate {
        
        let coordinate: Coordinate = Coordinate(x: 0, y: 0)
        var x1 = point.x
        var y1 = point.y - 115
        
        var count: Int = -1
        repeat {
            x1 = x1 - gameView.cellEdgeLength
            count++
        }
        while x1 > 0
        coordinate.x = count
        
        count = 10
        repeat {
            y1 = y1 + gameView.cellEdgeLength
            count--
        }
        while y1 < (gameView.cellEdgeLength * 10)
        coordinate.y = count
        
        return coordinate
    }
    
    func isValidTouch(point: CGPoint) -> Bool {
        if (point.x < 0 || point.x > 320) {
            return false
        }
        else if (point.y < 115 || point.y > 435) {
            return false
        }
        else {
            return true
        }
    }

}
