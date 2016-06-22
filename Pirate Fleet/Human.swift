//
//  Human.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 8/27/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - Human
// Used to give students a clean interface 😉!

protocol Human {
    func addShipToGrid(_ ship: Ship)
    func addMineToGrid(_ mine: _Mine_)
}

// MARK: - HumanObject

class HumanObject: Player, Human {
    
    // MARK: Properties
    
    let controlCenter = ControlCenter()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerType = .human
        self.availableMoves.append(.normalMove)
    }
    
    // MARK: Modify Grid
    
    func addShipToGrid(_ ship: Ship) {
        let _ = gridViewController.addShip(ship)
    }
    
    func addMineToGrid(_ mine: _Mine_) {
        let _ = gridViewController.addMine(mine)
    }
    
    override func addPlayerShipsMines(_ numberOfMines: Int = 0) {
        controlCenter.addShipsAndMines(self)
    }
    
    // MARK: Calculate Final Score
    
    func calculateScore(_ computer: Computer) -> String {

        let gameStats = GameStats(numberOfHitsOnEnemy: numberOfHits, numberOfMissesByHuman: numberOfMisses, enemyShipsRemaining: 5 - computer.gridViewController.numberSunk(), humanShipsSunk: gridViewController.numberSunk(), sinkBonus: 100, shipBonus: 100, guessPenalty: 10)
        
        return "Final Score: \(controlCenter.calculateFinalScore(gameStats))"
    }
}
