//
//  CharacterSprite.swift
//  SeniorProject
//
//  Created by Sebastian Connelly (student LM) on 5/11/18.
//  Copyright © 2018 Sebastian Connelly (student LM). All rights reserved.
//

import SpriteKit

protocol CharacterSprite {
    var attack: Int { get set }
    var health: Int { get set }
    var range: Int { get set }
    var movement: Int { get set }
    var team: String { get set }
    var hasMoved: Bool { get set }
    var canAttackAfterMoving: Bool { get set }
    
    init(team: String)
    
    func move(locations: [[Int]]) -> [[Bool]]
}
