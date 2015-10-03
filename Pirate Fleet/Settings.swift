//
//  Settings.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 8/25/15.
//  Copyright © 2015 Udacity, Inc. All rights reserved.
//

// MARK: - Settings

struct Settings {
    
    static var DefaultGridSize = GridSize(width: 8, height: 8)
    static var ComputerDifficulty = Difficulty.Advanced
    static var RequiredShips: [ShipSize:Int] = [
        .Small: 1,
        .Medium: 2,
        .Large: 1,
        .XLarge: 1
    ]
    static var RequiredMines = 2
    static var DefaultMineText = "Ka-Bam"
    
    struct Messages {
        static var GameOver = "Game Over"
        static var Win = "You won! Congrats!"
        static var Lose = "You've been defeated by the computer."
        static var Reset = "Reset Game"
        static var UnableToStart = "Cannot Start Game!"
        static var HumanHitMine = "You've hit a mine! You've lost a turn and the computer has made another move."
        static var ComputerHitMine = "The computer hit a mine! The computer loses a turn and you get to make another move!"
        static var DismissMineAlert = "Keep Firing!"
        static var BaseRequirementsNotMet = "You do not have the correct amount of ships/mines. You need one small ship (size of 2), two medium ships (size of 3), one large ship (size of 4), one x-large ship (size of 5)."
        static var AdvancedRequirementsNotMet = "You do not have the correct amount of ships/mines. You need one small ship (size of 2), two medium ships (size of 3), one large ship (size of 4), one x-large ship (size of 5), and two mines."
    }
    
    struct Images {
        static var Hit = "Hit"
        static var Miss = "Miss"
        static var ShipEndRight = "ShipEndRight"
        static var ShipEndLeft = "ShipEndLeft"
        static var ShipEndDown = "ShipEndDown"
        static var ShipEndUp = "ShipEndUp"
        static var ShipBodyHorz = "ShipBodyHorz"
        static var ShipBodyVert = "ShipBodyVert"
        static var MineHit = "MineHit"
        static var Mine = "Mine"
        static var Water = "Water"
    }
}
