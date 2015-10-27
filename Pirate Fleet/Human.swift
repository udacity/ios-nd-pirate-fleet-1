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
    func addShipToGrid(ship: Ship)
    func addMineToGrid(mine: _Mine_)
}

// MARK: - HumanObject

class HumanObject: Player, Human {
    
    // MARK: Properties
    
    let controlCenter = ControlCenter()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerType = .Human
        self.availableMoves.append(.NormalMove)
    }
    
    // MARK: Modify Grid
    
    func addShipToGrid(ship: Ship) {
        gridViewController.addShip(ship)
    }
    
    func addMineToGrid(mine: _Mine_) {
        gridViewController.addMine(mine)
    }
    
    override func addPlayerShipsMines(numberOfMines: Int = 0) {
        controlCenter.addShipsAndMines(self)
    }
    
    // MARK: Calculate Final Score
    
    func calculateScore(computer: Computer) -> String {

        let gameStats = GameStats(numberOfHitsOnEnemy: numberOfHits, numberOfMissesByHuman: numberOfMisses, enemyShipsRemaining: 5 - computer.gridViewController.numberSunk(), humanShipsSunk: gridViewController.numberSunk(), sinkBonus: 100, shipBonus: 100, guessPenalty: 10)
        
        return "Final Score: \(controlCenter.calculateFinalScore(gameStats))"
    }
}