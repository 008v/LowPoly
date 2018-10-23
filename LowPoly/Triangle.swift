//
//  Triangle.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/11.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import UIKit

public struct Triangle {
    public let p0: Point
    public let p1: Point
    public let p2: Point
    
    public init(p0: Point, p1: Point, p2: Point) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
    }
}

extension Triangle {
    
    public func area() -> Double {
        let x1 = p0.x
        let y1 = p0.y
        let x2 = p1.x
        let y2 = p1.y
        let x3 = p2.x
        let y3 = p2.y
        return abs(x1 * y2 + x2 * y3 + x3 * y1 - x1 * y3 - x2 * y1 - x3 * y2) / 2
    }
    
    public func incircle() -> Incircle {
        return Incircle(incenter: incenter(), radius: incircleRadius())
    }
    
    public func centroid() -> Point {
        return Point(x: (p0.x + p1.x + p2.x) / 3, y: (p0.y + p1.y + p2.y) / 3)
    }
    
    public func incenter() -> Point {
        let x1 = p0.x
        let y1 = p0.y
        let x2 = p1.x
        let y2 = p1.y
        let x3 = p2.x
        let y3 = p2.y
        let a = sqrt(pow(x2 - x3, 2) + pow(y2 - y3, 2))
        let b = sqrt(pow(x1 - x3, 2) + pow(y1 - y3, 2))
        let c = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2))
        let incenterX = (a * x1 + b * x2 + c * x3) / (a + b + c)
        let incenterY = (a * y1 + b * y2 + c * y3) / (a + b + c)
        return Point(x: incenterX, y: incenterY)
    }
    
    public func incircleRadius() -> Double {
        let x1 = p0.x
        let y1 = p0.y
        let x2 = p1.x
        let y2 = p1.y
        let x3 = p2.x
        let y3 = p2.y
        let a = sqrt(pow(x2 - x3, 2) + pow(y2 - y3, 2))
        let b = sqrt(pow(x1 - x3, 2) + pow(y1 - y3, 2))
        let c = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2))
        let s = area()
        return 2 * s / (a + b + c)
    }
}

extension Triangle {
    public func toPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: p0.cgPoint())
        path.addLine(to: p1.cgPoint())
        path.addLine(to: p2.cgPoint())
        path.addLine(to: p0.cgPoint())
        path.closeSubpath()
        return path
    }
}
