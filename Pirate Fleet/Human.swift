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
    }
    
    // MARK: Skip Turn
    
    func skipTurn() {
        skipNextTurn = false
        if let playerDelegate = playerDelegate {
            playerDelegate.playerDidMove(self)
        }
    }
    
    // MARK: Modify Grid
    
    func addShipToGrid(ship: Ship) {
        gridViewController.addShip(ship)
    }
    
    func addMineToGrid(mine: _Mine_) {
        gridViewController.addMine(mine)
    }
    
    override func addPlayerShipsAndMines(numberOfMines: Int = 0) {
        controlCenter.addShipsAndMines(self)
    }
    
    // MARK: Calculate Final Score
    
    func calculateScore() -> String {

        let gameStats = GameStats(numberOfHitsOnEnemy: 0, numberOfMissesByHuman: 0, enemyShipsRemaining: 0, humanShipsSunk: 0, sinkBonus: 0, shipBonus: 0, guessPenalty: 0)
        
        return "Final Score: \(controlCenter.calculateFinalScore(gameStats))"
    }
}