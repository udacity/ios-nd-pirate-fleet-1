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
    func playerDidMove(_ player: Player)
    func playerDidWin(_ player: Player)
    func playerDidSinkAtLocation(_ player: Player, location: GridLocation)
}

// MARK: - PirateFleetViewController

class PirateFleetViewController: UIViewController {
    
    // MARK: Properties
    
    var computer: Computer!
    var human: HumanObject!
    var readyToPlay: Bool = false
    var gameOver: Bool = false
            
    // MARK: Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initializeGame()
    }
    
    // MARK: Initialize Game
    
    func initializeGame() {
        
        // initialize human player first
        let numberOfMines = setupHuman()
        
        // computer must match the number of penalty items added by human
        setupComputer(numberOfMines)
        
        // determine if the proper amount of ships/mines given
        let readyState = checkReadyToPlay(numberOfMines)
        
        // are we ready to play?
        switch(readyState) {
        case .ReadyToPlay:
            readyToPlay = true
            gameOver = false
        case .ShipsMinesNotReady:
            readyToPlay = false
            gameOver = true
            print(Settings.Messages.ShipsMinesNotReady)
            createAlertWithTitle(Settings.Messages.UnableToStartTitle, message: readyState.rawValue, completionHandler: nil)
        case .ShipsNotReady:
            readyToPlay = false
            gameOver = true
            print(Settings.Messages.ShipsNotReady)
            createAlertWithTitle(Settings.Messages.UnableToStartTitle, message: readyState.rawValue, completionHandler: nil)
        case .Invalid:
            readyToPlay = false
            gameOver = true
        }
    }
    
    func setupHuman() -> Int {
        if human != nil {
            human.reset()
            human.addPlayerShipsMines()
        } else {
            human = HumanObject(frame: CGRect(x: self.view.frame.size.width / 2 - 120, y: self.view.frame.size.height - 256, width: 240, height: 240))
            human.playerDelegate = self
            human.addPlayerShipsMines()
            self.view.addSubview(human.gridView)
        }
        return human.numberOfMines()
    }
    
    func setupComputer(_ numberOfMines: Int) {
        if computer != nil {
            computer.reset()
            computer.addPlayerShipsMines(numberOfMines)
        } else {
            computer = Computer(frame: CGRect(x: self.view.frame.size.width / 2 - 180, y: self.view.frame.size.height / 2 - 300, width: 360, height: 360))
            computer.playerDelegate = self
            computer.gridDelegate = self
            computer.addPlayerShipsMines(numberOfMines)
            self.view.addSubview(computer.gridView)
        }
    }
    
    // MARK: Check If Ready To Play

    func checkReadyToPlay(_ numberOfMines: Int) -> ReadyState {
        switch (numberOfMines) {
        case 0:
            return (human.readyToPlay(checkMines: false) && computer.readyToPlay(checkMines: false)) ? .ReadyToPlay : .ShipsNotReady
        case 1...2:
            return (human.readyToPlay() && computer.readyToPlay()) ? .ReadyToPlay : .ShipsMinesNotReady
        default:
            return .Invalid
        }
    }
    
    // MARK: Alert
    
    func createAlertWithTitle(_ title: String, message: String, actionMessage: String? = nil, completionHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actionMessage = actionMessage {
            let action = UIAlertAction(title: actionMessage, style: .default, handler: completionHandler)
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func dismissPenaltyAlert(_ player: Player) {
        player.lastHitPenaltyCell = nil
        nextMove(player)
    }
}

// MARK: - PirateFleetViewController: GridViewDelegate

extension PirateFleetViewController: GridViewDelegate {
    func didTapCell(_ location: GridLocation) {
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
    
    func playerDidMove(_ player: Player) {
        
        // we've used a move
        player.availableMoves.removeLast()
        
        // which player was attacked?
        let attackedPlayer = (player.playerType == .human) ? computer : human
        
        // if any penalties incurred during the move, show alert
        if let mine = player.lastHitPenaltyCell {            
            attackedPlayer.availableMoves.append(.normalMove)
            
            let alertMessage = (player.playerType == .human) ? Settings.Messages.HumanHitMine : Settings.Messages.ComputerHitMine
            createAlertWithTitle(mine.explosionText, message: alertMessage, actionMessage: Settings.Messages.DismissAction, completionHandler: { (action) in
                self.dismissPenaltyAlert(player)
            })
        } else {
            nextMove(player)
        }        
    }
    
    func playerDidWin(_ player: Player) {
        
        if gameOver == false {
            switch player.playerType {
                
            // human won!
            case .human:
                createAlertWithTitle(Settings.Messages.GameOverTitle, message: Settings.Messages.GameOverWin, actionMessage: Settings.Messages.ResetAction, completionHandler: { (action) in
                    self.initializeGame()
                })
                
            // computer won!
            case .computer:
                createAlertWithTitle(Settings.Messages.GameOverTitle, message: Settings.Messages.GameOverLose, actionMessage: Settings.Messages.ResetAction, completionHandler: { (action) in
                    self.initializeGame()
                })
            }
            
            // print final score
            print(human.calculateScore(computer))
        }
    }
    
    func playerDidSinkAtLocation(_ player: Player, location: GridLocation) {
        if player.playerType == .human {
            computer.revealShipAtLocation(location)
        }
    }
    
    // MARK: Take Next Move
    
    func nextMove(_ player: Player) {
        (player.playerType == .human) ? self.nextHumanMove() : self.nextComputerMove()
    }
    
    func nextHumanMove() {
        if human.availableMoves.isEmpty {
            computer.availableMoves.append(.normalMove)
            computer.attack(human)
        } else {
            let nextMove: MoveType = human.availableMoves.last!
            if nextMove == .guaranteedHit {
                human.attackPlayerWithGuaranteedHit(computer)
            }
        }
    }
    
    func nextComputerMove() {
        if computer.availableMoves.isEmpty {
            human.availableMoves.append(.normalMove)
        } else {
            let nextMove: MoveType = computer.availableMoves.last!
            if nextMove == .guaranteedHit {
                computer.attackPlayerWithGuaranteedHit(human)
            } else {
                computer.attack(human)
            }
        }
    }
}
