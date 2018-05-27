//
//  GameScene.swift
//  SeniorProject
//
//  Created by Sebastian Connelly (student LM) on 4/1/18.
//  Copyright © 2018 Sebastian Connelly (student LM). All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene, UIGestureRecognizerDelegate {
    
    var cam: SKCameraNode?
    var previousPoint = CGPoint.zero
    
    var endTurnLabel: SKLabelNode = SKLabelNode()
    
    var waterTileMap: SKTileMapNode = SKTileMapNode()
    var landTileMap: SKTileMapNode = SKTileMapNode()
    var terrainTileMap: SKTileMapNode = SKTileMapNode()
    var charactersTileMap: SKTileMapNode = SKTileMapNode()
    var resourceTileMap: SKTileMapNode = SKTileMapNode()
    var extraStuffTileMap: SKTileMapNode = SKTileMapNode()
    var defenseTileMap: SKTileMapNode = SKTileMapNode()
    var movementTileMap: SKTileMapNode = SKTileMapNode()
    var highlightTileMap: SKTileMapNode = SKTileMapNode()
    
    var landMap: [[Bool]] = [[Bool]]()
    var terrainMap: [[Int]] = [[Int]]()
    var characterMap: [[CharacterSprite?]] = [[CharacterSprite?]]()
    var defenseMap: [[DefenseSprite?]] = [[DefenseSprite?]]()
    var resourceMap: [[String]] = [[String]]()
    var bridgeMap: [[Bool]] = [[Bool]]()
    
    var isMoving: Bool = false
    var isAttacking: Bool = false
    var touchLocations: [(Int, Int)] = [(Int, Int)]()
    var previousTouchLocation: (row: Int, column: Int) = (0,0)
    var turn: String = "Red"
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam!)
        
        loadSceneNodes()
        loadMaps()
        
        endTurnLabel = SKLabelNode(text: "End Turn")
        endTurnLabel.fontColor = .black
        endTurnLabel.fontName = "Chalkduster"
        endTurnLabel.fontSize = 40
        endTurnLabel.position = CGPoint(x: cam!.frame.width+270, y: 635)
        cam?.addChild(endTurnLabel)
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(moveCamera))
        recognizer.delegate = self
        self.view?.addGestureRecognizer(recognizer)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        self.previousPoint = self.cam!.position
        return true
    }
    
    @objc func moveCamera(_ sender: UIPanGestureRecognizer) {
        let transPoint = sender.translation(in: self.view)
        let newPosition = CGPoint(x: self.previousPoint.x - transPoint.x, y: transPoint.y + self.previousPoint.y)
        self.cam?.position = newPosition
    }
    
    func loadSceneNodes(){
        for node in self.children {
            if node.name == "Water Tiles" {
                waterTileMap = node as! SKTileMapNode
            } else if node.name == "Land Tiles" {
                landTileMap = node as! SKTileMapNode
            } else if node.name == "Terrain Tiles" {
                terrainTileMap = node as! SKTileMapNode
            } else if node.name == "Character Tiles" {
                charactersTileMap = node as! SKTileMapNode
            } else if node.name == "Resource Tiles" {
                resourceTileMap = node as! SKTileMapNode
            } else if node.name == "Extra Stuff Tiles" {
                extraStuffTileMap = node as! SKTileMapNode
            } else if node.name == "Defense Tiles" {
                defenseTileMap = node as! SKTileMapNode
            } else if node.name == "Movement Tiles" {
                movementTileMap = node as! SKTileMapNode
            } else if node.name == "Highlight Tiles" {
                highlightTileMap = node as! SKTileMapNode
            }
        }
    }
    
    func loadMaps(){
        
        for row in 0..<landTileMap.numberOfRows {
            var r = [Bool]()
            for col in 0..<landTileMap.numberOfColumns {
                let tile = landTileMap.tileDefinition(atColumn: col, row: row)
                
                if tile == nil {
                    r.append(false)
                } else {
                    r.append(true)
                }
            }
            landMap.append(r)
        }
        
        for row in 0..<terrainTileMap.numberOfRows {
            var r = [Int]()
            for col in 0..<terrainTileMap.numberOfColumns {
                let tile = terrainTileMap.tileDefinition(atColumn: col, row: row)
                
                if tile == nil {
                    if landMap[row][col] {
                        r.append(1)
                    } else {
                        r.append(99)
                    }
                } else {
                    if let moveCost = tile?.userData?.value(forKey: "MovementCost") as? Int {
                        r.append(moveCost)
                    }
                }
                
            }
            terrainMap.append(r)
        }
        
        for row in 0..<charactersTileMap.numberOfRows {
            var r = [CharacterSprite?]()
            for col in 0..<charactersTileMap.numberOfColumns {
                let tile = charactersTileMap.tileDefinition(atColumn: col, row: row)
                
                if tile == nil {
                    r.append(nil)
                } else {
                    if let unit = tile?.userData?.value(forKey: "Unit") as? String, let team = tile?.userData?.value(forKey: "Team") as? String {
                        if unit == "Archer" {
                            r.append(Archer(team: team))
                        } else if unit == "Spear Guy" {
                            r.append(SpearGuy(team: team))
                        } else if unit == "Knight" {
                            r.append(Knight(team: team))
                        } else if unit == "Mounted Knight" {
                            r.append(MountedKnight(team: team))
                        } else if unit == "Catapult" {
                            r.append(Catapult(team: team))
                        } else {
                            r.append(Trebuchet(team: team))
                        }
                    } else {
                        r.append(nil)
                    }
                }
                
            }
            characterMap.append(r)
        }
        
        for row in 0..<defenseTileMap.numberOfRows {
            var r = [DefenseSprite?]()
            for col in 0..<defenseTileMap.numberOfColumns {
                let tile = defenseTileMap.tileDefinition(atColumn: col, row: row)
                
                if tile == nil {
                    r.append(nil)
                } else {
                    if let unit = tile?.userData?.value(forKey: "Type") as? String, let team = tile?.userData?.value(forKey: "Team") as? String {
                        if unit == "Tower" {
                            r.append(Tower(team: team))
                        } else if unit == "Castle", let corner = tile?.userData?.value(forKey: "Corner") as? String {
                            r.append(Castle(team: team, corner: corner))
                        }
                    } else {
                        r.append(nil)
                    }
                }
            }
            defenseMap.append(r)
        }
        
        for row in 0..<resourceTileMap.numberOfRows {
            var r = [String]()
            for col in 0..<resourceTileMap.numberOfColumns {
                let tile = defenseTileMap.tileDefinition(atColumn: col, row: row)
                
                if tile == nil {
                    r.append("")
                } else {
                    
                }
            }
            resourceMap.append(r)
        }
        
        for row in 0..<extraStuffTileMap.numberOfRows {
            var r = [Bool]()
            for col in 0..<extraStuffTileMap.numberOfColumns {
                let tile = extraStuffTileMap.tileDefinition(atColumn: col, row: row)
                
                if tile == nil {
                    r.append(false)
                } else {
                    if let _ = tile?.userData?.value(forKey: "Bridge") {
                        r.append(true)
                    } else {
                        r.append(false)
                    }
                }
            }
            bridgeMap.append(r)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { fatalError("Touches not loaded") }
        
        let touchLocation = touch.location(in: self)
        let newTouchLocation = CGPoint(x: touchLocation.x/3.5, y: touchLocation.y/3.5)
        
        
        
        let column = charactersTileMap.tileColumnIndex(fromPosition: newTouchLocation)
        let row = charactersTileMap.tileRowIndex(fromPosition: newTouchLocation)
        
        if endTurnLabel.contains(touchLocation) {
            if checkGameOver() {
                touch.view?.isUserInteractionEnabled = false
                gameOver()
            } else if turn == "Red" {
                turn = "Blue"
            } else {
                turn = "Red"
            }
        } else if isMoving || isAttacking {
            if touchLocations.contains(where: {$0 == row && $1 == column ? true : false}) {
                
                let r = previousTouchLocation.row
                let c = previousTouchLocation.column
                
                guard let unit = characterMap[r][c] else {
                    fatalError("Unit Not Available")
                }
                
                let name = String(describing: unit).replacingOccurrences(of: "SeniorProject.", with: "")
                
                guard let characters = charactersTileMap.tileSet.tileGroups.first(where: {$0.name == "\(name)"}), let charactersTileSetRule = characters.rules.first(where: {$0.name == "Tile"}), let character = charactersTileSetRule.tileDefinitions.first(where: {$0.name == "\(name) \(unit.team)"
                }) else {
                    fatalError("Loading Screwed Up")
                }
                
                guard let healths = movementTileMap.tileSet.tileGroups.first(where: {$0.name == "Health"}) else {
                    fatalError("Health tiles not found")
                }
                
                guard let healthsTileSetRule = healths.rules.first(where: {$0.name=="Tile"}) else {
                    fatalError("TileSetRule not found")
                }
                
                guard let healthCounter = healthsTileSetRule.tileDefinitions.first(where: {$0.name == "Health \(unit.health)"}) else {
                    fatalError("Tile no found")
                }
                
                guard let highlight = highlightTileMap.tileDefinition(atColumn: column, row: row) else {
                    fatalError("Highlight not found")
                }
                
                if let color = highlight.userData?.value(forKey: "Highlight") as? String {
                    if color == unit.team {
                        movementTileMap.setTileGroup(nil, forColumn: c, row: r)
                        charactersTileMap.setTileGroup(nil, forColumn: c, row: r)
                        charactersTileMap.setTileGroup(characters, andTileDefinition: character, forColumn: column, row: row)
                        movementTileMap.setTileGroup(healths, andTileDefinition: healthCounter, forColumn: column, row: row)
                        
                        characterMap[row][column] = characterMap[r][c]
                        characterMap[row][column]!.hasMoved = true
                        characterMap[r][c] = nil
                    } else {
                        if var unit2 = characterMap[row][column] {
                            
                            unit2.health -= unit.attack
                            
                            if unit2.health <= 0 {
                                charactersTileMap.setTileGroup(nil, forColumn: column, row: row)
                                movementTileMap.setTileGroup(nil, forColumn: column, row: row)
                                characterMap[row][column] = nil
                            } else {
                                guard let newHealth = healthsTileSetRule.tileDefinitions.first(where: {$0.name == "Health \(unit2.health)"}) else {
                                    fatalError("New health not loaded")
                                }
                                
                                movementTileMap.setTileGroup(healths, andTileDefinition: newHealth, forColumn: column, row: row)
                            }
                            
                            characterMap[r][c]!.hasAttacked = true
                            
                        } else {
                            
                            if let castle = defenseMap[row][column] as? Castle {
                                
                                castle.health -= unit.attack
                                
                                if castle.health <= 0 {
                                    touch.view?.isUserInteractionEnabled = false
                                    gameOver()
                                } else {
                                    guard let newHealth = healthsTileSetRule.tileDefinitions.first(where: {$0.name == "Health \(castle.health)"}) else {
                                        fatalError("New health not loaded")
                                    }
                                    
                                    movementTileMap.setTileGroup(healths, andTileDefinition: newHealth, forColumn: column+1, row: row)
                                }
                                
                            } else if let tower = defenseMap[row][column] as? Tower {
                                //Do Tower stuff
                            }
                            
                            characterMap[r][c]!.hasAttacked = true
                            
                        }
                    }
                }
                
            }
            
            for (r, c) in touchLocations {
                highlightTileMap.setTileGroup(nil, forColumn: c, row: r)
            }
            
            isMoving = false
            isAttacking = false
            
            touchLocations.removeAll()
            
        } else if let unit = characterMap[row][column], unit.team == turn{
            if !unit.hasMoved && !unit.hasAttacked {
                let possibleLocations = getSquare(column: column, row: row)
                let actualLocations = unit.move(locations: possibleLocations)
                let attackLocations = getUnitSquare(range: unit.range, column: column, row: row, team: unit.team)
                
                isMoving = true
                
                previousTouchLocation = (row, column)
                setHighlights(col: column-2, row: row+2, locations: actualLocations, team: unit.team)
                
                if unit.team == "Red" {
                    setHighlights(col: column-unit.range, row: row+unit.range, locations: attackLocations, team: "Blue")
                } else {
                    setHighlights(col: column-unit.range, row: row+unit.range, locations: attackLocations, team: "Red")
                }
                
            } else if unit.canAttackAfterMoving && !unit.hasAttacked && unit.hasMoved {
                
                let possibleLocations = getUnitSquare(range: unit.range, column: column, row: row, team: unit.team)
                
                setHighlights(col: column-unit.range, row: row+unit.range, locations: possibleLocations, team: unit.team)
                
                isAttacking = true
                
            }
            
        }
        
    }
    
    func setHighlights(col: Int, row: Int, locations: [[Bool]], team: String) {
        
        guard let highlights = highlightTileMap.tileSet.tileGroups.first(where: {$0.name == "Highlight"}) else {
            fatalError("Highlight tiles not found")
        }
        
        guard let highlightsTileSetRule = highlights.rules.first(where: {$0.name=="Tile"}) else {
            fatalError("TileSetRule not found")
        }
        
        guard let highlightTeamColor = highlightsTileSetRule.tileDefinitions.first(where: {$0.name == "Highlight \(team)"}) else {
            fatalError("Tile no found")
        }
        
        guard let highlightsLarge = highlightTileMap.tileSet.tileGroups.first(where: {$0.name == "Highlight Large"}), let highlightsLargeTileSetRule = highlightsLarge.rules.first(where: {$0.name == "Tile"}), let largeHighlightTeamColor = highlightsLargeTileSetRule.tileDefinitions.first(where: {$0.name == "Highlight \(team) Large"}) else {
            fatalError("Large Highlights Not Loaded")
        }
        
        for r in 0 ..< locations.count {
            for c in 0 ..< locations[r].count {
                if locations[r][c] {
                    if let _ = defenseMap[row-r][col+c] as? Castle {
                        highlightTileMap.setTileGroup(highlightsLarge, andTileDefinition: largeHighlightTeamColor, forColumn: col+c, row: row-r)
                        touchLocations.append((row-r, col+c))
                    } else {
                        highlightTileMap.setTileGroup(highlights, andTileDefinition: highlightTeamColor, forColumn: col+c, row: row-r)
                        touchLocations.append((row-r, col+c))
                    }
                }
            }
        }
        
    }
    
    func checkGameOver() -> Bool {
        for i in characterMap {
            for character in i {
                if character?.team != "\(turn)" {
                    return false
                }
            }
        }
        return true
    }
    
    func gameOver() {
        let gameOverLabel = SKLabelNode(text: "\(turn) Wins!")
        gameOverLabel.fontColor = .black
        gameOverLabel.fontName = "Helvetica Neue"
        gameOverLabel.fontSize = 100
        gameOverLabel.position = CGPoint(x: cam!.frame.midX, y: cam!.frame.midY)
        addChild(gameOverLabel)
    }
    
    func getUnitSquare(range: Int, column: Int, row: Int, team: String) -> [[Bool]] {
        var possibleLocations: [[Bool]] = Array(repeating: Array(repeating: false, count: range*2+1), count: range*2+1)
        
        for r in 0..<possibleLocations.count {
            let expression = (2*range)-abs(range-r)
            for j in abs(range-r)...expression{
                if let unit = characterMap[(row+range)-r][(column-range)+j], unit.team != team{
                    possibleLocations[r][j] = true
                } else if let defense = defenseMap[(row+range)-r][(column-range)+j], defense.team != team {
                    if let castle = defense as? Castle {
                        if castle.corner == "Bottom Right" {
                            possibleLocations[r][j-1] = true
                        } else if castle.corner == "Bottom Left" {
                            possibleLocations[r][j] = true
                        } else if castle.corner == "Top Right" {
                            possibleLocations[r+1][j-1] = true
                        } else if castle.corner == "Top Left" {
                            possibleLocations[r+1][j] = true
                        }
                    } else {
                        possibleLocations[r][j] = true
                    }
                }
            }
        }
        
        return possibleLocations
    }
    
    func getSquare(column: Int, row: Int) -> [[Int]] {
        var possibleLocations: [[Int]] = Array(repeating: Array(repeating: 99, count: 5), count: 5)
        
        for r in 0..<5 {
            for j in abs(2-r)...4-abs(2-r){
                if characterMap[(row+2)-r][(column-2)+j] == nil && defenseMap[(row+2)-r][(column-2)+j] == nil {
                    if bridgeMap[(row+2)-r][(column-2)+j] {
                        possibleLocations[r][j] = 1
                    } else {
                        possibleLocations[r][j] = terrainMap[(row+2)-r][(column-2)+j]
                    }
                }
            }
        }
        
        return possibleLocations
    }
    
}
