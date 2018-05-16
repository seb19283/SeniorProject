//
//  Castle.swift
//  SeniorProject
//
//  Created by Sebastian Connelly (student LM) on 5/15/18.
//  Copyright © 2018 Sebastian Connelly (student LM). All rights reserved.
//

import SpriteKit

class Castle: DefenseSprite {
    var health: Int = 9
    var attack: Int = 4
    var range: Int = 2
    var team: String
    
    required init(team: String) {
        self.team = team
    }
    
}
