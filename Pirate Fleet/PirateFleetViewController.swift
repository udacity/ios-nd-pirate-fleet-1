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
            
    // MARK: Lifecycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.initializeGame()
    }
    
    // MARK: Initialize Game
    
    func initializeGame() {
        
        // initialize human player first
        let penaltyItems = setupHuman()
        
        // computer must match the number of penalty items added by human
        setupComputer(numberOfMines: penaltyItems.0, numberOfSeamonsters: penaltyItems.1)
        
        // determine if the proper amount of ships/mines/monsters given
        let readyState = checkReadyToPlay(numberOfMines: penaltyItems.0, numberOfSeamonsters: penaltyItems.1)
        
        // are we ready to play?
        switch(readyState) {
        case .ReadyToPlay:
            readyToPlay = true
            gameOver = false
        case .ShipsMonstersNotReady, .ShipsMinesNotReady, .ShipsMinesMonstersNotReady, .ShipsNotReady, .Invalid:
            readyToPlay = false
            gameOver = true
            createAlertWithTitle(Settings.Messages.UnableToStartTitle, message: readyState.rawValue, completionHandler: nil)
        }
    }
    
    func setupHuman() -> (Int, Int) {
        if human != nil {
            human.reset()
            human.addPlayerShipsMinesMonsters()
        } else {
            human = HumanObject(frame: CGRect(x: self.view.frame.size.width / 2 - 120, y: self.view.frame.size.height - 256, width: 240, height: 240))
            human.playerDelegate = self
            human.addPlayerShipsMinesMonsters()
            self.view.addSubview(human.gridView)
        }
        return (human.numberOfMines(), human.numberOfSeamonsters())
    }
    
    func setupComputer(numberOfMines numberOfMines: Int, numberOfSeamonsters: Int) {
        if computer != nil {
            computer.reset()
            computer.addPlayerShipsMinesMonsters(numberOfMines, numberOfSeamonsters: numberOfSeamonsters)
        } else {
            computer = Computer(frame: CGRect(x: self.view.frame.size.width / 2 - 180, y: self.view.frame.size.height / 2 - 300, width: 360, height: 360))
            computer.playerDelegate = self
            computer.gridDelegate = self
            computer.addPlayerShipsMinesMonsters(numberOfMines, numberOfSeamonsters: numberOfSeamonsters)
            self.view.addSubview(computer.gridView)
        }
    }
    
    // MARK: Check If Ready To Play

    func checkReadyToPlay(numberOfMines numberOfMines: Int, numberOfSeamonsters: Int) -> ReadyState {
        switch (numberOfMines, numberOfSeamonsters) {
        case (0, 0):
            return (human.readyToPlay(checkMines: false, checkMonsters: false) && computer.readyToPlay(checkMines: false, checkMonsters: false)) ? .ReadyToPlay : .ShipsNotReady
        case (0, 0...2):
            return (human.readyToPlay(checkMines: false) && computer.readyToPlay(checkMines: false)) ? .ReadyToPlay : .ShipsMinesMonstersNotReady
        case (0...2, 0):
            return (human.readyToPlay(checkMonsters: false) && computer.readyToPlay(checkMonsters: false)) ? .ReadyToPlay : .ShipsMinesNotReady
        case (0...2, 0...2):
            return (human.readyToPlay() && computer.readyToPlay()) ? .ReadyToPlay : .ShipsMinesMonstersNotReady
        default:
            return .Invalid
        }
    }
    
    // MARK: Alert
    
    func createAlertWithTitle(title: String, message: String, actionMessage: String? = nil, completionHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        if let actionMessage = actionMessage {
            let action = UIAlertAction(title: actionMessage, style: .Default, handler: completionHandler)
            alert.addAction(action)
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissPenaltyAlert(player: Player) {
        player.lastHitPenaltyCell = nil
        nextMove(player)
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
    
    // MARK: PlayerDelegate
    
    func playerDidMove(player: Player) {
        
        // we've used a move
        player.availableMoves.removeLast()
        
        // which player was attacked?
        let attackedPlayer = (player.playerType == .Human) ? computer : human
        
        // if any penalties incurred during the move, show alert
        if let penaltyCell = player.lastHitPenaltyCell {
            
            // mine penalty
            if let mine = penaltyCell as? Mine {
                attackedPlayer.availableMoves.append(.NormalMove)
                
                let alertMessage = (player.playerType == .Human) ? Settings.Messages.HumanHitMine : Settings.Messages.ComputerHitMine

                createAlertWithTitle(mine.penaltyText, message: alertMessage, actionMessage: Settings.Messages.DismissAction, completionHandler: { (action) in
                    self.dismissPenaltyAlert(player)
                })
            }
                
            // sea monster penalty
            else if let seamonster = penaltyCell as? SeaMonster {
                attackedPlayer.availableMoves.append(.GuaranteedHit)
                
                let alertMessage = (player.playerType == .Human) ? Settings.Messages.HumanHitMonster : Settings.Messages.ComputerHitMonster
                
                createAlertWithTitle(seamonster.penaltyText, message: alertMessage, actionMessage: Settings.Messages.DismissAction, completionHandler: { (action) in
                    self.dismissPenaltyAlert(player)
                })
            }
        } else {
            nextMove(player)
        }        
    }
    
    func playerDidWin(player: Player) {
        
        if gameOver == false {
            switch player.playerType {
                
            // human won!
            case .Human:
                createAlertWithTitle(Settings.Messages.GameOverTitle, message: Settings.Messages.GameOverWin, actionMessage: Settings.Messages.ResetAction, completionHandler: { (action) in
                    self.initializeGame()
                })
                
            // computer won!
            case .Computer:
                createAlertWithTitle(Settings.Messages.GameOverTitle, message: Settings.Messages.GameOverLose, actionMessage: Settings.Messages.ResetAction, completionHandler: { (action) in
                    self.initializeGame()
                })
            }
            
            // print final score
            print(human.calculateScore(computer))
        }
    }
    
    func playerDidSinkAtLocation(player: Player, location: GridLocation) {
        if player.playerType == .Human {
            computer.revealShipAtLocation(location)
        }
    }
    
    // MARK: Take Next Move
    
    func nextMove(player: Player) {
        (player.playerType == .Human) ? self.nextHumanMove() : self.nextComputerMove()
    }
    
    func nextHumanMove() {
        if human.availableMoves.isEmpty {
            computer.availableMoves.append(.NormalMove)
            computer.attack(human)
        } else {
            let nextMove: MoveType = human.availableMoves.last!
            if nextMove == .GuaranteedHit {
                human.attackPlayerWithGuaranteedHit(computer)
            }
        }
    }
    
    func nextComputerMove() {
        if computer.availableMoves.isEmpty {
            human.availableMoves.append(.NormalMove)
        } else {
            let nextMove: MoveType = computer.availableMoves.last!
            if nextMove == .GuaranteedHit {
                computer.attackPlayerWithGuaranteedHit(human)
            } else {
                computer.attack(human)
            }
        }
    }
}