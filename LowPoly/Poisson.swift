//
//  Poisson.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/23.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

/*
    http://www.it610.com/article/1567877.htm
 */

import UIKit

public class Poisson: NSObject {

    public override init() { }
    
    public func discSample(_ width: Double, height: Double, minDistance: Double, newPointsCount: Int) -> [Point] {
        
        // Create the grid
        let cellSize = minDistance / sqrt(2.0)
        let grid = Grid(width: width, height: height, cellSize: cellSize)
        
        // processList works like a queue, except that it pops a random element from the queue instead of the element at the head of the queue
        var processList = [Point]()
        var samplePoints = [Point]()
        
        // generate the first point randomly
        let firstPoint = Point(x: Double.random(0, width), y: Double.random(0, height))
        
        //update containers
        processList.append(firstPoint)
        samplePoints.append(firstPoint)
        grid.add(firstPoint)
        
        // generate other points from points in queue.
        while processList.isEmpty == false
        {
            guard let point = processList.popRandom() else {
                continue
            }
            for _ in stride(from: 0, to: newPointsCount, by: 1)
            {
                let newPoint = generateRandomPoint(around: point, minDistance: minDistance)
                // check that the point is in the image region and no points exists in the point's neighbourhood
                if newPoint.isInRect(width, height: height) == true && grid.inNeighbourhood(newPoint, minDistance: minDistance) == false
                {
                    //update containers
                    processList.append(newPoint)
                    samplePoints.append(newPoint)
                    grid.add(newPoint)
                }
            }
        }
        
        return samplePoints
    }
    
    fileprivate func generateRandomPoint(around point: Point, minDistance: Double) -> Point {
        // non-uniform, favours points closer to the inner ring, leads to denser packings
        
        let r1 = Double.random()    //random point between 0 and 1
        let r2 = Double.random()
        
        // random radius between minDistance and 2 * minDistance
        let radius = minDistance * (r1 + 1.0)
        
        // random angle
        let angle = 2 * Double.pi * r2
        
        // the new point is generated around the point (x, y)
        let newX = point.x + radius * cos(angle)
        let newY = point.y + radius * sin(angle)
        
        return Point(x: newX, y: newY)
    }
    
}

// MARK: - Extensions

extension Array {
    mutating func popRandom() -> Element? {
        if isEmpty { return nil }
        
        let index = Int(arc4random_uniform(UInt32(count)))
        let element = self[index]
        remove(at: index)
        return element
    }
}

extension Double {
    static func random() -> Double {
        return Double(arc4random()) / 0xFFFFffff
    }
    
    static func random(_ min: Double, _ max: Double) -> Double {
        return Double.random() * (max - min) + min
    }
}
