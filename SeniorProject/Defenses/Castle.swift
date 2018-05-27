//
//  Castle.swift
//  SeniorProject
//
//  Created by Sebastian Connelly (student LM) on 5/20/18.
//  Copyright © 2018 Sebastian Connelly (student LM). All rights reserved.
//

import Foundation

class Castle: DefenseSprite {
    var attack: Int = 0
    var health: Int = 9
    var range: Int = 2
    var team: String
    var corner: String
    
    required init(team: String) {
        self.team = team
        self.corner = ""
    }
    
    init(team: String, corner: String) {
        self.team = team
        self.corner = corner
    }
    
}
