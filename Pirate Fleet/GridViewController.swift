//
//  GridViewController.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 8/14/15.
//  Copyright © 2015 Udacity, Inc. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


// MARK: - GridViewController

class GridViewController {
    
    // MARK: Properties
    
    var gridView: GridView
    var metaShips: [MetaShip] = []
    var shipCounts: [ShipSize:Int] = [
        .small: 0,
        .medium: 0,
        .large: 0,
        .xLarge: 0
    ]
    var mineCount = 0
    
    // MARK: Initializers
    
    init(frame: CGRect, isInteractive: Bool = false) {
        gridView = GridView(frame: frame)
        gridView.isInteractive = isInteractive
    }
    
    func reset() {
        metaShips.removeAll(keepingCapacity: true)
        for shipSize in shipCounts.keys {
            shipCounts[shipSize] = 0
        }
        mineCount = 0
        gridView.reset()
        gridView.setNeedsDisplay()
    }
    
    // MARK: Add Ship
    
    func addShip(_ ship: Ship, playerType: PlayerType = .human) -> Bool {
        
        guard isShipRequired(ship) else {
            if let shipSize = ShipSize(rawValue: ship.length) , playerType == .human {
                print("ERROR: Cannot add \(ship). You already have enough \(shipSize) ships.")
            }
            return false
        }
        
        guard !isShipOutOfBounds(ship) else {
            if playerType == .human {
                print("ERROR: Cannot add \(ship). Ship is out of bounds.")
            }
            return false
        }
        
        guard !isShipOverlapping(ship) else {
            if playerType == .human {
                print("ERROR: Cannot add \(ship). Ship overlaps another ship.")
            }
            return false
        }
        
        let start = ship.location, end = ShipEndLocation(ship)
        let metaShip = MetaShip()
        
        for x in start.x...end.x {
            for y in start.y...end.y {
                
                metaShip.cells.append(gridView.grid[x][y].location)
                metaShip.cellsHit[gridView.grid[x][y].location] = false
                
                gridView.grid[x][y].containsObject = true
                gridView.grid[x][y].metaShip = metaShip
                
                // place "front-end" of ship
                if x == start.x && y == start.y {
                    if ship.isVertical {
                        gridView.markShipPieceAtLocation(GridLocation(x: x, y: y), orientation: .endUp, playerType: playerType)                    } else {
                        gridView.markShipPieceAtLocation(GridLocation(x: x, y: y), orientation: .endLeft, playerType: playerType)                    }
                    continue
                }
                
                // place "back-end" of ship
                if x == end.x && y == end.y {
                    if ship.isVertical {
                        gridView.markShipPieceAtLocation(GridLocation(x: x, y: y), orientation: .endDown, playerType: playerType)                    } else {
                        gridView.markShipPieceAtLocation(GridLocation(x: x, y: y), orientation: .endRight, playerType: playerType)                    }
                    continue
                }
                
                // place middle piece of ship
                gridView.markShipPieceAtLocation(GridLocation(x: x, y: y), orientation: ((ship.isVertical) ? .bodyVert : .bodyHorz), playerType: playerType)
            }
        }
        
        metaShips.append(metaShip)
        shipCounts[ShipSize(rawValue: ship.length)!]! += 1
        return true
    }
    
    // MARK: Add Mine
    
    func addMine(_ mine: _Mine_, playerType: PlayerType = .human) -> Bool {
        
        let x = mine.location.x, y = mine.location.y

        guard !isLocationOutOfBounds(mine.location) else {
            if playerType == .human {
                print("ERROR: Cannot add \(mine). Mine is out of bounds.")
            }
            return false
        }
        
        guard mineCount < Settings.RequiredMines && !gridView.grid[x][y].containsObject else {
            if playerType == .human {
                print("ERROR: Cannot add \(mine). You already have enough mines.")
            }
            return false
        }
        
        gridView.grid[x][y].containsObject = true
        gridView.grid[x][y].mine = mine
        gridView.markImageAtLocation(mine.location, image: Settings.Images.Mine, hidden: ((playerType == .computer) ? true : false))
        mineCount += 1
        return true
    }
    
    // MARK: Fire Cannon
    
    func fireCannonAtLocation(_ location: GridLocation) -> Bool {
        
        let x = location.x, y = location.y
        
        guard gridView.grid[x][y].containsObject else {
            return false
        }
        
        gridView.grid[x][y].metaShip?.cellsHit[location] = true
        if let mine = gridView.grid[x][y].mine {
            gridView.markImageAtLocation(mine.location, image: Settings.Images.MineHit)
        } else {
            gridView.markImageAtLocation(location, image: Settings.Images.Hit)
        }
        return true
    }
}

// MARK: - Pre-Game Checks

extension GridViewController {
    
    func hasRequiredShips() -> Bool {
        for (shipType, count) in shipCounts {
            if count != Settings.RequiredShips[shipType] {
                return false
            }
        }
        return true
    }
    
    func hasRequiredMines() -> Bool {
        return mineCount == Settings.RequiredMines
    }
}

// MARK: - In-Game Checks

extension GridViewController {
    
    func checkSink(_ location: GridLocation) -> Bool {
        guard (gridView.grid[location.x][location.y].mine == nil) else {
            return false
        }
        
        if let ship = gridView.grid[location.x][location.y].metaShip {
            return ship.sunk
        } else {
            return false
        }
    }
    
    func checkForWin() -> Bool {
        for ship in metaShips {
            if ship.sunk == false {
                return false
            }
        }
        return true
    }
    
    func numberSunk() -> Int {
        var numberSunk = 0
        for ship in metaShips {
            if ship.sunk == true {
                numberSunk += 1
            }
        }
        return numberSunk
    }
}

// MARK: - Adding Ship Checks

extension GridViewController {
    
    fileprivate func isLocationOutOfBounds(_ location: GridLocation) -> Bool {
        return (location.x >= Settings.DefaultGridSize.width || location.y >= Settings.DefaultGridSize.height || location.x < 0 || location.y < 0)
    }
    
    fileprivate func isShipOutOfBounds(_ ship: Ship) -> Bool {
        let start = ship.location, end = ShipEndLocation(ship)
        return (end.x >= Settings.DefaultGridSize.width || end.y >= Settings.DefaultGridSize.height || start.x < 0 || end.x < 0)
    }
    
    fileprivate func isShipRequired(_ ship: Ship) -> Bool {
        if let shipSize = ShipSize(rawValue: ship.length) {
            return shipCounts[shipSize] < Settings.RequiredShips[shipSize]
        } else {
            print("ERROR: Cannot add \(ship). Ship has an invalid length of \(ship.length).")
            return false
        }
    }
    
    fileprivate func isShipOverlapping(_ ship: Ship) -> Bool {
        let start = ship.location, end = ShipEndLocation(ship)
        for x in start.x...end.x {
            for y in start.y...end.y {
                if gridView.grid[x][y].containsObject { return true }
            }
        }
        return false
    }
}
