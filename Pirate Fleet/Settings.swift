//
//  Settings.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 8/25/15.
//  Copyright © 2015 Udacity, Inc. All rights reserved.
//

// MARK: - ReadyState: String

enum ReadyState: String {
    case ShipsNotReady = "You do not have the correct amount of ships. You need one small ship (size of 2), two medium ships (size of 3), one large ship (size of 4), one x-large ship (size of 5)."
    case ShipsMinesNotReady = "You do not have the correct amount of ships/mines. You need one small ship (size of 2), two medium ships (size of 3), one large ship (size of 4), one x-large ship (size of 5), and two mines."
    case ShipsMonstersNotReady = "You do not have the correct amount of ships/monsters. You need one small ship (size of 2), two medium ships (size of 3), one large ship (size of 4), one x-large ship (size of 5), and two sea monsters."
    case ShipsMinesMonstersNotReady = "You do not have the correct amount of ships/mines/monsters. You need one small ship (size of 2), two medium ships (size of 3), one large ship (size of 4), one x-large ship (size of 5), two mines, and two sea monsters."
    case ReadyToPlay = "All Ready!"
    case Invalid = "Invalid Ready State!"
}

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
    static var RequiredSeamonsters = 2
    
    static var DefaultMineText = "Boom!"
    static var DefaultMonsterText = "Yikes!"
    
    struct Messages {
        static var GameOverTitle = "Game Over"
        static var GameOverWin = "You won! Congrats!"
        static var GameOverLose = "You've been defeated by the computer."
        
        static var UnableToStartTitle = "Cannot Start Game"

        static var HumanHitMine = "You've hit a mine! The computer has been rewarded an extra move on their next turn."
        static var ComputerHitMine = "The computer has hit a mine! You've been awarded an extra move on your next turn."
        
        static var HumanHitMonster = "You've hit a sea monster! On the computer's next turn, they will get a guaranteed hit."
        static var ComputerHitMonster = "The computer has hit a sea monster! On your next turn, you'll get a guaranteed hit."
        
        static var ResetAction = "Reset Game"
        static var DismissAction = "Continue"
    }
    
    struct Images {
        static var Water = "Water"
        static var Hit = "Hit"
        static var Miss = "Miss"

        static var ShipEndRight = "ShipEndRight"
        static var ShipEndLeft = "ShipEndLeft"
        static var ShipEndDown = "ShipEndDown"
        static var ShipEndUp = "ShipEndUp"
        static var ShipBodyHorz = "ShipBodyHorz"
        static var ShipBodyVert = "ShipBodyVert"

        static var WoodenShipPlaceholder = "WoodenShipPlaceholder"
        
        static var Mine = "Mine"
        static var MineHit = "MineHit"
        
        static var SeaMonster = "Seamonster"
        static var SeaMonsterHit = "SeamonsterHit"
    }
}
