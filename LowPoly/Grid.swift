//
//  Grid.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/24.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import UIKit
import simd

class Grid: NSObject {
    
    let width: Int
    let height: Int
    let cellSize: Double
    var array: [[Point]]
    
    init(width: Double, height: Double, cellSize: Double) {
        self.width = Int(ceil(width / cellSize))
        self.height = Int(ceil(height / cellSize))
        self.cellSize = cellSize
        self.array = [[Point]](repeatElement([Point](repeatElement(Point.nan, count: self.width)), count: self.height))
    }
    
    func add(_ point: Point) {
        let gridPoint = self.gridPoint(point, cellSize: cellSize)
        array[Int(gridPoint.y)][Int(gridPoint.x)] = point
    }
    
     func inNeighbourhood(_ point: Point, minDistance: Double) -> Bool {
        let gridPoint = self.gridPoint(point, cellSize: cellSize)
        //get the neighbourhood if the point in the grid
        let cellsAroundPoint = square(around: gridPoint, extend: 2)
        for cell in cellsAroundPoint
        {
            let _point = self.array[cell.y][cell.x]
            if !_point.isNaN() {
                if point.distance(_point) < minDistance {
                    return true
                }
            }
        }
        return false
    }
    
    fileprivate func gridPoint(_ point: Point, cellSize: Double) -> GridPoint {
        let gridX = Int(point.x / cellSize)
        let gridY = Int(point.y / cellSize)
        return GridPoint(x: gridX, y: gridY)
    }
    
    fileprivate func square(around gridPoint: GridPoint, extend: Int = 2) -> [GridPoint] {
        var gridPoints = [GridPoint]()
        for y in stride(from: gridPoint.y - extend, to: gridPoint.y + extend, by: 1) {
            for x in stride(from: gridPoint.x - extend, to: gridPoint.x + extend, by: 1) {
                if x >= 0 && x < width && y >= 0 && y < height {
                    gridPoints.append(GridPoint(x: x, y: y))
                }
            }
        }
        return gridPoints
    }
}
