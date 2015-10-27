//
//  Computer.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 8/31/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - Computer

class Computer: Player {
    
    // MARK: Properties
    
    var gridDelegate: GridViewDelegate? {
        willSet {
            gridViewController.gridView.delegate = newValue
        }
    }
    private var nextMoves = Set<GridLocation>()
    private var shipHitTrace = [GridLocation]()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.gridViewController.gridView.isInteractive = true
    }
    
    override func reset() {
        super.reset()
        nextMoves.removeAll(keepCapacity: true)
        shipHitTrace.removeAll(keepCapacity: true)
    }
    
    // MARK: Attacking
    
    func attack(player: Player) {
        
        var move: GridLocation
        
        if !nextMoves.isEmpty {
            move = nextMoves.removeFirst()
        } else {
            nextMoves.insert(getRandomMove())
            move = nextMoves.removeFirst()
        }
        
        if let mine = player.grid[move.x][move.y].mine {
            lastHitPenaltyCell = mine
        }
        
        if player.gridViewController.fireCannonAtLocation(move) {
            shipHitTrace.append(move)
            if Settings.ComputerDifficulty == .Advanced && lastHitPenaltyCell == nil { addEducatedMoves() }
        } else {
            player.gridViewController.gridView.markImageAtLocation(move, image: Settings.Images.Miss)
        }
        
        performedMoves.insert(GridLocation(x: move.x, y: move.y))
        
        if let playerDelegate = playerDelegate {
            if player.gridViewController.checkForWin() {
                playerDelegate.playerDidWin(self)
            }
            playerDelegate.playerDidMove(self)
        }
    }
    
    // MARK: Adding New Moves
    
    private func addEducatedMoves() {
        guard shipHitTrace.count != 0 else { return }
        
        // attempt adjacent locations (N, S, E, W) for last element in hit trace
        let hit = shipHitTrace.last!
        let xMods: [Int] = [-1, 0, 1, 0]
        let yMods: [Int] = [0, -1, 0, 1]
        
        for i in 0..<xMods.count {
            let location = GridLocation(x: hit.x + xMods[i], y: hit.y + yMods[i])
            // special check since some adjacent locations will go off the grid
            if isEducatedMoveValid(location) { nextMoves.insert(location) }
        }
        
        if nextMoves.isEmpty { nextMoves.insert(getRandomMove()) }
    }
    
    private func isEducatedMoveValid(location: GridLocation) -> Bool {
        return locationInBounds(location) && !performedMoves.contains(location) && !nextMoves.contains(location)
    }
    
    private func getRandomMove() -> GridLocation {
        var randomMoveLocation = RandomGridLocation()
        while performedMoves.contains(randomMoveLocation) {
            randomMoveLocation = RandomGridLocation()
        }
        return randomMoveLocation
    }
}