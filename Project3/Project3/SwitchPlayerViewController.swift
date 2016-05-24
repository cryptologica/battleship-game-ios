//
//  SwitchPlayerViewController.swift
//  Project3
//
//  Created by JT Newsome on 3/21/16.
//  Copyright © 2016 JT Newsome. All rights reserved.
//

import UIKit

class SwitchPlayerViewController: UIViewController {
    
    var message: String = "Error: Message not set!"
    
    private var switchPlayerView: SwitchPlayerView! {
        return (view as! SwitchPlayerView)
    }
    
    override func loadView() {
        view = SwitchPlayerView(frame: CGRectZero)
        print("Loaded: SwitchPlayerViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        switchPlayerView.backgroundColor = UIColor.blackColor()
        switchPlayerView.messageLbl = UILabel(frame: CGRectMake(100, 100, 200, 100))
        switchPlayerView.messageLbl?.textColor = UIColor.whiteColor()
        switchPlayerView.messageLbl!.text = message
        switchPlayerView.addSubview(switchPlayerView.messageLbl!)
        
        switchPlayerView.confirmBtn = UIButton(frame: CGRectMake(100, 200, 100, 50))
        switchPlayerView.confirmBtn!.setTitle("OK", forState: .Normal)
        switchPlayerView.confirmBtn!.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        switchPlayerView.confirmBtn?.addTarget(self, action: "confirmBtnClicked", forControlEvents: .TouchDown)
        switchPlayerView.addSubview(switchPlayerView.confirmBtn!)
    }
    
    func confirmBtnClicked() {
        navigationController?.popViewControllerAnimated(true)
    }
}
