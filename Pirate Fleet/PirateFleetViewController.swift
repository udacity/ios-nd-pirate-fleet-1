//
//  PirateFleetViewController.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 8/14/15.
//  Copyright © 2015 Udacity, Inc. All rights reserved.
//

import UIKit

// MARK: - PlayerDelegate

protocol PlayerDelegate {
    func playerDidMove(player: Player)
    func playerDidWin(player: Player)
    func playerDidSinkAtLocation(player: Player, location: GridLocation)
}

// MARK: - PirateFleetViewController

class PirateFleetViewController: UIViewController {
    
    // MARK: Properties
    
    var computer: Computer!
    var human: HumanObject!
    var readyToPlay: Bool = false
    var gameOver: Bool = false
    var viewHasAppeared: Bool = false
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeGame()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !readyToPlay {
            endGameWithAlert(Settings.Messages.UnableToStart, withMessage: (human.numberOfMines() == 0) ? Settings.Messages.BaseRequirementsNotMet : Settings.Messages.AdvancedRequirementsNotMet)
        }
        
        viewHasAppeared = true
    }
    
    // MARK: Initialize Game
    
    func initializeGame() {
        
        // initialize player first, check the number of mines
        setupPlayer()
        let numberOfMines = human.numberOfMines()
        
        // computer must match the number of mines
        setupComputer(numberOfMines)
        
        // are we ready to play?
        readyToPlay = (numberOfMines == 0) ? human.readyToPlay(checkMines: false) && computer.readyToPlay(checkMines: false) : human.readyToPlay() && computer.readyToPlay()
        
        if !readyToPlay && viewHasAppeared {
            endGameWithAlert(Settings.Messages.UnableToStart, withMessage: (numberOfMines == 0) ? Settings.Messages.BaseRequirementsNotMet : Settings.Messages.AdvancedRequirementsNotMet)
        }
        
        gameOver = false
    }
    
    func setupPlayer() {
        if human != nil {
            human.reset()
            human.addPlayerShipsAndMines()
        } else {
            human = HumanObject(frame: CGRect(x: self.view.frame.size.width / 2 - 120, y: self.view.frame.size.height - 256, width: 240, height: 240))
            human.playerDelegate = self
            human.addPlayerShipsAndMines()
            self.view.addSubview(human.gridView)
        }
    }
    
    func setupComputer(numberOfMines: Int) {
        if computer != nil {
            computer.reset()
            computer.addPlayerShipsAndMines(numberOfMines)
        } else {
            computer = Computer(frame: CGRect(x: self.view.frame.size.width / 2 - 180, y: self.view.frame.size.height / 2 - 300, width: 360, height: 360))
            computer.playerDelegate = self
            computer.gridDelegate = self
            computer.addPlayerShipsAndMines(numberOfMines)
            self.view.addSubview(computer.gridView)
        }
    }

    // MARK: Alert
    
    func endGameWithAlert(title: String, withMessage: String, withActionMessage: String? = nil) {
        gameOver = true
        let alert = UIAlertController(title: title, message: withMessage, preferredStyle: .Alert)
        if let withActionMessage = withActionMessage {
            let action = UIAlertAction(title: withActionMessage, style: .Default) { (action) in
                self.initializeGame()
            }
            alert.addAction(action)
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func pauseGameWithMineAlert(explosionText: String, affectedPlayerType: PlayerType) {
        let alertText = (affectedPlayerType == .Human) ? Settings.Messages.HumanHitMine : Settings.Messages.ComputerHitMine
        let alert = UIAlertController(title: explosionText + "!", message: alertText, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: Settings.Messages.DismissMineAlert, style: .Default, handler: nil)
        alert.addAction(dismissAction)
        self.presentViewController(alert, animated: true, completion: nil)         
    }
}

// MARK: - PirateFleetViewController: GridViewDelegate

extension PirateFleetViewController: GridViewDelegate {
    func didTapCell(location: GridLocation) {
        if readyToPlay {
            if human.canAttackPlayer(computer, atLocation: location) {
                human.attackPlayer(computer, atLocation: location)
            }
        }        
    }
}

// MARK: - PirateFleetViewController: PlayerDelegate

extension PirateFleetViewController: PlayerDelegate {
    
    func playerDidMove(player: Player) {
        switch player.playerType {
        case .Human:
            // human finished moving, should we skip the computer?
            if computer.skipNextTurn {
                computer.skipNextTurn = false
            } else {
                computer.attack(human)
                
                // did human hit a mine?
                if let mine = human.lastHitMine where human.skipNextTurn {
                    // yes, then invokes playerDidMove again to "skip"
                    pauseGameWithMineAlert(mine.explosionText, affectedPlayerType: player.playerType)
                    human.skipTurn()
                }
            }            
        case .Computer:
            if let mine = computer.lastHitMine where computer.skipNextTurn {
                pauseGameWithMineAlert(mine.explosionText, affectedPlayerType: player.playerType)
            }
        }
    }

    func playerDidWin(player: Player) {
        if gameOver == false {
            switch player.playerType {
            case .Human:
                endGameWithAlert(Settings.Messages.GameOver, withMessage: Settings.Messages.Win, withActionMessage: Settings.Messages.Reset)
            case .Computer:
                endGameWithAlert(Settings.Messages.GameOver, withMessage: Settings.Messages.Lose, withActionMessage: Settings.Messages.Reset)
            }
            
            print(human.calculateScore(computer))
        }
    }
    
    func playerDidSinkAtLocation(player: Player, location: GridLocation) {
        if player.playerType == .Human {
            computer.revealShipAtLocation(location)
        }
    }
}