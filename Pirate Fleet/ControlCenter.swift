//
//  ControlCenter.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 9/2/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

struct GridLocation {
    let x: Int
    let y: Int
}

struct Ship {
    let length: Int
    let location: GridLocation
    let isVertical: Bool
}

class ControlCenter {

    func addShipsAndMines(human: Human) {
        
        let mediumShip1 = Ship(length: 3, location: GridLocation(x: 0, y: 0), isVertical: false)
        
        human.addShipToGrid(mediumShip1)
        
    }
            
    func calculateFinalScore(gameStats: GameStats) -> Int {
        
        var finalScore: Int
                        
        finalScore = 0
                
        return finalScore
    }
}