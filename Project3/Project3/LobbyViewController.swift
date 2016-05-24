//
//  GameListViewController.swift
//  Project3
//
//  Created by JT Newsome on 3/18/16.
//  Copyright © 2016 JT Newsome. All rights reserved.
//
//
//
//
// READ ME :D :D :D
// * You can delete games by swiping left and clicking the delete button!
// * NSPath thing doesn't work/deprecated in my version of Swift, I just used NSUserDefaults
//
//
//
//
//
import UIKit

protocol GameViewControllerDelegate: class {
    
    func sendDataToGameView(sender: LobbyViewController, game: Game, gameIndex: Int)
}

class LobbyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LobbyViewControllerDelegate {
    
    weak var delegate: GameViewControllerDelegate? = nil
    
    var gameList: [Game] = []
    var tableView: UITableView = UITableView()
    let cellSpacingHeight: CGFloat = 1
    
    private var lobbyView: LobbyView! {
        return (view as! LobbyView)
    }
    
    override func loadView() {
        view = LobbyView(frame: CGRectZero)
        print("Loaded: LobbyViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Lobby"
        loadGameListData()
        
        if (gameList.count == 0) {
            let p1: Player =  Player(isTurn: false)
            let p2: Player = Player(isTurn: false)
            let newGame: Game  = Game(player1: p1, player2: p2, isAddTile: true)
            gameList.append(newGame)
        }
        
        let gameListRect = CGRectMake(10, 0, UIScreen.mainScreen().bounds.width - 20, UIScreen.mainScreen().bounds.height)
        tableView = UITableView(frame: gameListRect, style: UITableViewStyle.Grouped)
        
        tableView.backgroundColor = UIColor.darkGrayColor()
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.scrollEnabled = true
        tableView.bounces = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(GameTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(GameTableViewCell))
        
        view.addSubview(tableView)
        
        //clearSavedData()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    // Called upon receiving data from GameVC
    func sendDataToLobbyView(sender: GameViewController, game: Game, gameIndex: Int) {
        gameList[gameIndex] = game
        saveGameListData()
        print("Received Update From Game")
        tableView.reloadData()
    }
    
    func clearSavedData() {
        gameList.removeAll()
        saveGameListData()
    }
    
    // MARK: Save/Load
    func saveGameListData() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(gameList)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "gameListData")
    }
    
    func loadGameListData() {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("gameListData") as? NSData {
            gameList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Game]
        }
    }
    
    // MARK: Table: Game List
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(GameTableViewCell), forIndexPath: indexPath) as! GameTableViewCell
        cell.game = gameList[indexPath.section]
        
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.whiteColor()
        
        if (cell.game!.player1!.numShipsAlive == 0) {
            cell.layer.borderColor = UIColor.redColor().CGColor
        }
        else if (cell.game!.player2!.numShipsAlive == 0) {
            cell.gameStatusLabel.text = "Player 1 Won!"
            cell.layer.borderColor = UIColor.redColor().CGColor
        }
        else {
            cell.layer.borderColor = UIColor.blackColor().CGColor
        }
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
        
    }
    
    // When user clicks on a Game Tile...
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("You selected cell #\(indexPath.section)!")
        
        let nextVC = GameViewController(nibName: "GameViewController", bundle: nil)
        self.delegate = nextVC
        let selectedGame = gameList[indexPath.section]
        
        // Send selected game
        if (selectedGame.isAddTile == false) {
            delegate?.sendDataToGameView(self, game: selectedGame, gameIndex: indexPath.section)
            print("Opening Selected Game...")
        }
        // Send new game
        else {
            let p1: Player = Player(isTurn: true)
            let p2: Player = Player(isTurn: false)
            let newGame: Game  = Game(player1: p1, player2: p2, isAddTile: false)
            let gameIndex = gameList.count
            gameList.append(newGame)
            delegate?.sendDataToGameView(self, game: newGame, gameIndex: gameIndex)
            print("Starting New Game...")
        }
        
        saveGameListData()
        tableView.reloadData()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // Num Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Num Sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return gameList.count
    }
    
    // Row Height
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let g = gameList[indexPath.section]
        if (g.isAddTile == true) {
            return 30
        }
        return 120
    }
    
    // Set the spacing between sections
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    
    // Make the background color show through
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (indexPath.section == 0) {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            gameList.removeAtIndex(indexPath.section)
            saveGameListData()
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
