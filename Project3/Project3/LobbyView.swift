//
//  GameListView.swift
//  Project3
//
//  Created by JT Newsome on 3/18/16.
//  Copyright © 2016 JT Newsome. All rights reserved.
//

import UIKit

class LobbyView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.darkGrayColor()
        print("Loaded: LobbyView")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}