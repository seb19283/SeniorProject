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
    
    var waterTileMap: SKTileMapNode = SKTileMapNode()
    var landTileMap: SKTileMapNode = SKTileMapNode()
    var terrainTileMap: SKTileMapNode = SKTileMapNode()
    var charactersTileMap: SKTileMapNode = SKTileMapNode()
    var resourceTileMap: SKTileMapNode = SKTileMapNode()
    var extraStuffTileMap: SKTileMapNode = SKTileMapNode()
    var defenseTileMap: SKTileMapNode = SKTileMapNode()
    var movementTileMap: SKTileMapNode = SKTileMapNode()
    
    var landMap: [[Bool]] = [[Bool]]()
    var terrainMap: [[Int]] = [[Int]]()
    var characterMap: [[CharacterSprite?]] = [[CharacterSprite?]]()
    var defenseMap: [[DefenseSprite?]] = [[DefenseSprite?]]()
    
    var isMoving: Bool = false
    var touchLocations: [(Int, Int)] = [(Int, Int)]()
    var previousTouchLocation: (row: Int, column: Int) = (0,0)
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam!)
        
        loadSceneNodes()
        loadMaps()
        
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
                        } else if unit == "Castle" {
                            r.append(Castle(team: team))
                        }
                    } else {
                        r.append(nil)
                    }
                }
            }
            defenseMap.append(r)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { fatalError("Touches not loaded") }

        let touchLocation = touch.location(in: self)
        let newTouchLocation = CGPoint(x: touchLocation.x/3.5, y: touchLocation.y/3.5)
        
        let column = charactersTileMap.tileColumnIndex(fromPosition: newTouchLocation)
        let row = charactersTileMap.tileRowIndex(fromPosition: newTouchLocation)
        
        if isMoving {
            if touchLocations.contains(where: {$0 == row && $1 == column ? true : false}) {
                
                let r = previousTouchLocation.row
                let c = previousTouchLocation.column
                
                guard let unit = characterMap[r][c] else {
                    fatalError("Unit Not Available")
                }
                
                var name = String(describing: unit).replacingOccurrences(of: "SeniorProject.", with: "")
                
                if name == "MountedKnight" {
                    name = "Mounted Knight"
                } else if name == "SpearGuy" {
                    name = "Spear Guy"
                }
                
                guard let characters = charactersTileMap.tileSet.tileGroups.first(where: {$0.name == "\(name)"}), let charactersTileSetRule = characters.rules.first(where: {$0.name == "Tile"}), let character = charactersTileSetRule.tileDefinitions.first(where: {$0.name == "\(name) \(unit.team)"
                }) else {
                    fatalError("Loading Screwed Up")
                }
                
                let healthTile = movementTileMap.tileDefinition(atColumn: c, row: r)
                
                guard let health = healthTile?.userData?.value(forKey: "Health") as? Int else {
                    fatalError("No Health")
                }
                
                guard let healths = movementTileMap.tileSet.tileGroups.first(where: {$0.name == "Health"}) else {
                    fatalError("Health tiles not found")
                }
                
                guard let healthsTileSetRule = healths.rules.first(where: {$0.name=="Tile"}) else {
                    fatalError("TileSetRule not found")
                }
                
                guard let healthCounter = healthsTileSetRule.tileDefinitions.first(where: {$0.name == "Move \(health)"}) else {
                    fatalError("Tile no found")
                }
                
                movementTileMap.setTileGroup(nil, forColumn: c, row: r)
                charactersTileMap.setTileGroup(nil, forColumn: c, row: r)
                movementTileMap.setTileGroup(healths, andTileDefinition: healthCounter, forColumn: column, row: row)
                charactersTileMap.setTileGroup(characters, andTileDefinition: character, forColumn: column, row: row)
                
                loadMaps()
                
            }
            
            for (r, c) in touchLocations {
                movementTileMap.setTileGroup(nil, forColumn: c, row: r)
            }
            
            isMoving = !isMoving
            touchLocations.removeAll()
            
        } else if let unit = characterMap[row][column]{
            if !unit.hasMoved {
                let possibleLocations = getSquare(column: column, row: row)
                let actualLocations = unit.move(locations: possibleLocations)
                
                isMoving = true
                
                previousTouchLocation = (row, column)
                setHighlights(col: column, row: row, locations: actualLocations, team: unit.team)
            } else {
                if unit.canAttackAfterMoving {
                    
                }
            }
            
        }
        
    }
    
    func setHighlights(col: Int, row: Int, locations: [[Bool]], team: String) {
        
        guard let highlights = movementTileMap.tileSet.tileGroups.first(where: {$0.name == "Highlight"}) else {
            fatalError("Highlight tiles not found")
        }
        
        guard let highlightsTileSetRule = highlights.rules.first(where: {$0.name=="Tile"}) else {
            fatalError("TileSetRule not found")
        }
        
        guard let highlightTeamColor = highlightsTileSetRule.tileDefinitions.first(where: {$0.name == "Highlight \(team)"}) else {
            fatalError("Tile no found")
        }
        
        for r in 0 ..< locations.count {
            for c in 0 ..< locations[r].count {
                if locations[r][c] {
                    movementTileMap.setTileGroup(highlights, andTileDefinition: highlightTeamColor, forColumn: (col-2)+c, row: (row+2)-r)
                    touchLocations.append(((row+2)-r, (col-2)+c))
                }
            }
        }
        
    }
    
    func getSquare(column: Int, row: Int) -> [[Int]] {
        var possibleLocations: [[Int]] = Array(repeating: Array(repeating: 99, count: 5), count: 5)
        
        for r in 0..<5 {
            for j in abs(2-r)...4-abs(2-r){
                if characterMap[(row+2)-r][(column-2)+j] == nil && defenseMap[(row+2)-r][(column-2)+j] == nil {
                    possibleLocations[r][j] = terrainMap[(row+2)-r][(column-2)+j]
                }
            }
        }
        
        return possibleLocations
    }
    
}
