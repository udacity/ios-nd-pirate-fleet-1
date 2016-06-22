//
//  Enums.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 8/26/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

// MARK: - PlayerType

enum PlayerType {
    case human, computer
}

// MARK: - ShipPieceOrientation

enum ShipPieceOrientation {
    case endUp, endDown, endLeft, endRight, bodyVert, bodyHorz
}

// MARK: - Difficulty

enum Difficulty: Int {
    case basic = 0, advanced
}

// MARK: - ShipSize

enum ShipSize: Int {
    case small = 2, medium = 3, large = 4, xLarge = 5
}
