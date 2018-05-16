//
//  Archer.swift
//  SeniorProject
//
//  Created by Sebastian Connelly (student LM) on 5/14/18.
//  Copyright © 2018 Sebastian Connelly (student LM). All rights reserved.
//

import SpriteKit

class Archer: CharacterSprite {
    
    var attack: Int = 2
    var health: Int = 2
    var range: Int = 2
    var movement: Int = 2
    var hasMoved: Bool = false
    var canAttackAfterMoving: Bool = true
    var team: String
    
    required init(team: String) {
        self.team = team
    }
    
    func move(locations: [[Int]]) -> [[Bool]] {
        var possibleMoves: [[Bool]] = [[Bool]]()
        
        for row in 0..<locations.count {
            var possibleMovesInRow: [Bool] = [Bool]()
            for col in 0..<locations[row].count {
                if locations[row][col] == 99 {
                    possibleMovesInRow.append(false)
                } else {
                    if (col == 2 && (row > 0 && row < 4)) || (row == 2 && (col > 0 && col < 4)){
                        if locations[row][col] > movement {
                            possibleMovesInRow.append(false)
                        } else {
                            possibleMovesInRow.append(true)
                        }
                    } else {
                        if col == 2 {
                            if row == 0 {
                                if locations[row][col] + locations[row+1][col] > movement {
                                    possibleMovesInRow.append(false)
                                } else {
                                    possibleMovesInRow.append(true)
                                }
                            } else {
                                if locations[row][col] + locations[row-1][col] > movement {
                                    possibleMovesInRow.append(false)
                                } else {
                                    possibleMovesInRow.append(true)
                                }
                            }
                        } else if row == 2 {
                            if col == 0 {
                                if locations[row][col] + locations[row][col+1] > movement {
                                    possibleMovesInRow.append(false)
                                } else {
                                    possibleMovesInRow.append(true)
                                }
                            } else {
                                if locations[row][col] + locations[row][col-1] > movement {
                                    possibleMovesInRow.append(false)
                                } else {
                                    possibleMovesInRow.append(true)
                                }
                            }
                        } else {
                            if col == 1 {
                                if row == 1 {
                                    if (locations[row][col] + locations[row][col+1] > movement) && (locations[row][col] + locations[row+1][col] > movement) {
                                        possibleMovesInRow.append(false)
                                    } else {
                                        possibleMovesInRow.append(true)
                                    }
                                } else {
                                    if (locations[row][col] + locations[row][col+1] > movement) && (locations[row][col] + locations[row-1][col] > movement) {
                                        possibleMovesInRow.append(false)
                                    } else {
                                        possibleMovesInRow.append(true)
                                    }
                                }
                            } else {
                                if row == 1 {
                                    if (locations[row][col] + locations[row][col-1] > movement) && (locations[row][col] + locations[row+1][col] > movement) {
                                        possibleMovesInRow.append(false)
                                    } else {
                                        possibleMovesInRow.append(true)
                                    }
                                } else {
                                    if (locations[row][col] + locations[row][col-1] > movement) && (locations[row][col] + locations[row-1][col] > movement) {
                                        possibleMovesInRow.append(false)
                                    } else {
                                        possibleMovesInRow.append(true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            possibleMoves.append(possibleMovesInRow)
        }
        
        possibleMoves[2][2] = false
        
        return possibleMoves
    }
    
}
