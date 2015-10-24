//
//  Structs.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 8/26/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - GridSize

struct GridSize {
    let width: Int
    let height: Int
}

// MARK: - GridCell

struct GridCell {
    let location: GridLocation
    let view: UIView
    var containsObject: Bool
    var mine: Mine?
    var ship: Ship?
    var seamonster: SeaMonster?
}

// MARK: - GameStats

struct GameStats {
    let numberOfHitsOnEnemy: Int
    let numberOfMissesByHuman: Int
    let enemyShipsRemaining: Int
    let humanShipsSunk: Int
    let sinkBonus: Int
    let shipBonus: Int
    let guessPenalty: Int
}

// MARK: - HitTracker

class HitTracker {
    var cellsHit: [GridLocation: Bool] = [:]
}