//
//  Triangle.swift
//  DelaunayTriangulation
//
//  Created by WEI QIN on 2018/10/11.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import UIKit

public struct Triangle {
    public let vertex0: Vertex
    public let vertex1: Vertex
    public let vertex2: Vertex
    
    public init(vertex0: Vertex, vertex1: Vertex, vertex2: Vertex) {
        self.vertex0 = vertex0
        self.vertex1 = vertex1
        self.vertex2 = vertex2
    }
}

extension Triangle {
    
    public func area() -> Double {
        let x1 = vertex0.x
        let y1 = vertex0.y
        let x2 = vertex1.x
        let y2 = vertex1.y
        let x3 = vertex2.x
        let y3 = vertex2.y
        return abs(x1 * y2 + x2 * y3 + x3 * y1 - x1 * y3 - x2 * y1 - x3 * y2) / 2
    }
    
    public func incircle() -> Incircle {
        return Incircle(incenter: incenter(), radius: incircleRadius())
    }
    
    public func centroid() -> Vertex {
        return Vertex(x: (vertex0.x + vertex1.x + vertex2.x) / 3, y: (vertex0.y + vertex1.y + vertex2.y) / 3)
    }
    
    public func incenter() -> Vertex {
        let x1 = vertex0.x
        let y1 = vertex0.y
        let x2 = vertex1.x
        let y2 = vertex1.y
        let x3 = vertex2.x
        let y3 = vertex2.y
        let a = sqrt(pow(x2 - x3, 2) + pow(y2 - y3, 2))
        let b = sqrt(pow(x1 - x3, 2) + pow(y1 - y3, 2))
        let c = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2))
        let incenterX = (a * x1 + b * x2 + c * x3) / (a + b + c)
        let incenterY = (a * y1 + b * y2 + c * y3) / (a + b + c)
        return Vertex(x: incenterX, y: incenterY)
    }
    
    public func incircleRadius() -> Double {
        let x1 = vertex0.x
        let y1 = vertex0.y
        let x2 = vertex1.x
        let y2 = vertex1.y
        let x3 = vertex2.x
        let y3 = vertex2.y
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
        path.move(to: vertex0.cgPoint())
        path.addLine(to: vertex1.cgPoint())
        path.addLine(to: vertex2.cgPoint())
        path.addLine(to: vertex0.cgPoint())
        path.closeSubpath()
        return path
    }
}
