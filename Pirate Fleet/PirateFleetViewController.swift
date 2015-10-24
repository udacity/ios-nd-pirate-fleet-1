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
        let penaltyItems = setupPlayer()
        
        // computer must match the number of penalty items added by human
        setupComputer(penaltyItems.0, numberOfSeamonsters: penaltyItems.1)
        
        // determine if the proper amount of ships/mines/monsters given
        let readyState = checkReadyToPlay(penaltyItems.0, numberOfSeamonsters: penaltyItems.1)
        
        // are we ready to play?
        switch(readyState) {
        case .ReadyToPlay:
            readyToPlay = true
            gameOver = false
        case .ShipsMonstersNotReady, .ShipsMinesNotReady, .ShipsMinesMonstersNotReady, .ShipsNotReady, .Invalid:
            readyToPlay = false
            gameOver = true
            createAlertWithCompletion(Settings.Messages.UnableToStartTitle, message: readyState.rawValue, completionHandler: nil)
        }
    }
    
    func setupPlayer() -> (Int, Int) {
        if human != nil {
            human.reset()
            human.addPlayerShipsMinesAndMonsters()
        } else {
            human = HumanObject(frame: CGRect(x: self.view.frame.size.width / 2 - 120, y: self.view.frame.size.height - 256, width: 240, height: 240))
            human.playerDelegate = self
            human.addPlayerShipsMinesAndMonsters()
            self.view.addSubview(human.gridView)
        }
        return (human.numberOfMines(), human.numberOfSeamonsters())
    }
    
    func setupComputer(numberOfMines: Int, numberOfSeamonsters: Int) {
        if computer != nil {
            computer.reset()
            computer.addPlayerShipsMinesAndMonsters(numberOfMines, numberOfSeamonsters: numberOfSeamonsters)
        } else {
            computer = Computer(frame: CGRect(x: self.view.frame.size.width / 2 - 180, y: self.view.frame.size.height / 2 - 300, width: 360, height: 360))
            computer.playerDelegate = self
            computer.gridDelegate = self
            computer.addPlayerShipsMinesAndMonsters(numberOfMines, numberOfSeamonsters: numberOfSeamonsters)
            self.view.addSubview(computer.gridView)
        }
    }
    
    // MARK: Check If Ready To Play

    func checkReadyToPlay(numberOfMines: Int, numberOfSeamonsters: Int) -> ReadyState {
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
    
    func createAlertWithCompletion(title: String, message: String, actionMessage: String? = nil, completionHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        if let actionMessage = actionMessage {
            let action = UIAlertAction(title: actionMessage, style: .Default, handler: completionHandler)
            alert.addAction(action)
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func pauseGameWithMineAlert(explosionText: String, attackingPlayer: Player, attackedPlayer: Player) {
        let alertText = (attackingPlayer.playerType == .Human) ? Settings.Messages.HumanHitMine : Settings.Messages.ComputerHitMine
        let alert = UIAlertController(title: explosionText + "!", message: alertText, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: Settings.Messages.DismissAction, style: .Default) { (action) -> Void in

            attackingPlayer.lastHitPenaltyCell = nil
            
            if attackingPlayer.playerType == .Human {
                self.processNextTurnForHuman()
            } else {
                self.processNextTurnForComputer()
            }
        }
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
    
    func processNextTurnForHuman() {
        if human.availableMoves.isEmpty {
            computer.availableMoves.append(.NormalMove)
            if computer.numberOfMines() != 0 {
                computer.attackMine(human)
            } else {
                computer.attack(human)
            }
        } else {
            let nextMove: MoveType = human.availableMoves.last!
            if nextMove == .GuaranteedHit {
                human.attackPlayerWithGuaranteedHit(computer)
            }
        }
    }
    
    func processNextTurnForComputer() {
        
        if computer.availableMoves.isEmpty {
            human.availableMoves.append(.NormalMove)
        } else {
            let nextMove: MoveType = computer.availableMoves.last!
            if nextMove == .GuaranteedHit {
                computer.attackPlayerWithGuaranteedHit(human)
            } else {
                if computer.numberOfMines() != 0 {
                    computer.attackMine(human)
                } else {
                    computer.attack(human)
                }
            }
        }
    }
    
    func playerDidMove(player: Player) {
        
        // we've used a move
        player.availableMoves.removeLast()
        
        // which player was attacked?
        let attackedPlayer = (player.playerType == .Human) ? computer : human
        
        // alert of any penalties incurred during the move
        if let penaltyCell = player.lastHitPenaltyCell {            
            if let mine = penaltyCell as? Mine {
                attackedPlayer.availableMoves.append(.NormalMove)
                
                let alertMessage = (player.playerType == .Human) ? Settings.Messages.HumanHitMine : Settings.Messages.ComputerHitMine

                createAlertWithCompletion(mine.penaltyText, message: alertMessage, actionMessage: Settings.Messages.DismissAction, completionHandler: { (action) in
                    
                    player.lastHitPenaltyCell = nil

                    if player.playerType == .Human {
                        self.processNextTurnForHuman()
                    } else {
                        self.processNextTurnForComputer()
                    }
                })
            } else if let seamonster = penaltyCell as? SeaMonster {
                attackedPlayer.availableMoves.append(.GuaranteedHit)
                
                let alertMessage = (player.playerType == .Human) ? Settings.Messages.HumanHitMonster : Settings.Messages.ComputerHitMonster
                
                createAlertWithCompletion(seamonster.penaltyText, message: alertMessage, actionMessage: Settings.Messages.DismissAction, completionHandler: { (action) in
                    
                    player.lastHitPenaltyCell = nil
                    
                    if player.playerType == .Human {
                        self.processNextTurnForHuman()
                    } else {
                        self.processNextTurnForComputer()
                    }
                })
            }
        } else {
            if player.playerType == .Human {
                processNextTurnForHuman()
            } else {
                processNextTurnForComputer()
            }
        }        
    }
    
    func playerDidWin(player: Player) {
        if gameOver == false {
            switch player.playerType {
            case .Human:
                createAlertWithCompletion(Settings.Messages.GameOverTitle, message: Settings.Messages.GameOverWin, actionMessage: Settings.Messages.ResetAction, completionHandler: { (action) in
                    self.initializeGame()
                })
            case .Computer:
                createAlertWithCompletion(Settings.Messages.GameOverTitle, message: Settings.Messages.GameOverLose, actionMessage: Settings.Messages.ResetAction, completionHandler: { (action) in
                    self.initializeGame()
                })
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