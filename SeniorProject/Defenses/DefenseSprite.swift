//
//  DefenseSprite.swift
//  SeniorProject
//
//  Created by Sebastian Connelly (student LM) on 5/15/18.
//  Copyright © 2018 Sebastian Connelly (student LM). All rights reserved.
//

import SpriteKit

protocol DefenseSprite {
    var health: Int { get set }
    var attack: Int { get set }
    var range: Int { get set }
    var team: String { get set }
    
    init(team: String)
}
