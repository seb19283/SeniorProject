//
//  Tower.swift
//  SeniorProject
//
//  Created by Sebastian Connelly (student LM) on 5/15/18.
//  Copyright © 2018 Sebastian Connelly (student LM). All rights reserved.
//

import SpriteKit

class Tower: DefenseSprite {
    var health: Int = 4
    var attack: Int = 3
    var range: Int = 2
    var team: String
    
    required init(team: String) {
        self.team = team
    }
    
}
