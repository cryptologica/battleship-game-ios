//
//  GameListTableView.swift
//  Project3
//
//  Created by JT Newsome on 3/18/16.
//  Copyright © 2016 JT Newsome. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    var gameStatusLabel: UILabel!
    var playerOneLabel: UILabel!
    var playerTwoLabel: UILabel!
    var playerOneShipsAliveLabel: UILabel!
    var playerTwoShipsAliveLabel: UILabel!
    
    var game: Game? {
        
        didSet {
            
            if let g = game {
                if (g.isPlayPhase == false) {
                    gameStatusLabel.text = "In Placement"
                }
                else if (g.player1!.numShipsAlive == 0) {
                    gameStatusLabel.text = "Player 2 Won!"
                    gameStatusLabel.textColor = UIColor.greenColor()
                }
                else if (g.player2!.numShipsAlive == 0) {
                    gameStatusLabel.text = "Player 1 Won!"
                    gameStatusLabel.textColor = UIColor.greenColor()
                }
                else if (g.player1!.isTurn == true) {
                    gameStatusLabel.text = "Player 1's Turn"
                }
                else if (g.player2!.isTurn == true) {
                    gameStatusLabel.text = "Player 2's Turn"
                }
                else {
                    gameStatusLabel.text = "Error?"
                }
                
                playerOneShipsAliveLabel.text = "Ships Alive: " + String(g.player1!.numShipsAlive)
                playerTwoShipsAliveLabel.text = "Ships Alive: " + String(g.player2!.numShipsAlive)
                
                if (g.isAddTile == true) {
                    gameStatusLabel.text = "New Game"
                    playerOneShipsAliveLabel.text = ""
                    playerTwoShipsAliveLabel.text = ""
                    playerOneLabel.text = ""
                    playerTwoLabel.text = ""
                }
                
                setNeedsLayout()
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clearColor()
        
        gameStatusLabel = UILabel(frame: CGRectZero)
        gameStatusLabel.textColor = UIColor.blackColor()
        contentView.addSubview(gameStatusLabel)
        
        playerOneLabel = UILabel(frame: CGRectZero)
        playerOneLabel.textColor = UIColor.blackColor()
        playerOneLabel.text = "Player 1"
        contentView.addSubview(playerOneLabel)
        
        playerTwoLabel = UILabel(frame: CGRectZero)
        playerTwoLabel.textColor = UIColor.blackColor()
        playerTwoLabel.text = "Player 2"
        contentView.addSubview(playerTwoLabel)
        
        playerOneShipsAliveLabel = UILabel(frame: CGRectZero)
        playerOneShipsAliveLabel.textColor = UIColor.blackColor()
        contentView.addSubview(playerOneShipsAliveLabel)
        
        playerTwoShipsAliveLabel = UILabel(frame: CGRectZero)
        playerTwoShipsAliveLabel.textColor = UIColor.blackColor()
        contentView.addSubview(playerTwoShipsAliveLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerOneLabel.frame = CGRectMake(25, 50, 110, 25)
        playerOneShipsAliveLabel.frame = CGRectMake(25, 75, 110, 25)
        
        playerTwoLabel.frame = CGRectMake(frame.width - 110, 50, 110, 25)
        playerTwoShipsAliveLabel.frame = CGRectMake(frame.width - 110, 75, 110, 25)
        
        gameStatusLabel.frame = CGRectMake(100, 5, 115, 25)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
