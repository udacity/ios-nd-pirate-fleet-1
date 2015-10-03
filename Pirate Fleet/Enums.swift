//
//  Enums.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 8/26/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

// MARK: - PlayerType

enum PlayerType {
    case Human, Computer
}

// MARK: - ShipPieceOrientation

enum ShipPieceOrientation {
    case EndUp, EndDown, EndLeft, EndRight, BodyVert, BodyHorz
}

// MARK: - Difficulty

enum Difficulty: Int {
    case Basic = 0, Advanced
}

// MARK: - ShipSize

enum ShipSize: Int {
    case Small = 2, Medium = 3, Large = 4, XLarge = 5
}