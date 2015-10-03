//
//  Functions.swift
//  Pirate Fleet
//
//  Created by Jarrod Parkes on 9/1/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import Foundation

// MARK: - Generate random grid location

func RandomGridLocation() -> GridLocation {
    let randomX = Int(arc4random_uniform(UInt32(Settings.DefaultGridSize.width)))
    let randomY = Int(arc4random_uniform(UInt32(Settings.DefaultGridSize.height)))
    return GridLocation(x: randomX, y: randomY)
}

// MARK: - Calculate GridLocation for ship's end position

func ShipEndLocation(ship: Ship) -> GridLocation {
    return ship.isVertical ? GridLocation(x: ship.location.x, y: ship.location.y + ship.length - 1) : GridLocation(x: ship.location.x + ship.length - 1, y: ship.location.y)
}
