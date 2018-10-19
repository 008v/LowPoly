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
    public func centroid() -> CGPoint {
        return CGPoint(x: (vertex0.x + vertex1.x + vertex2.x) / 3, y: (vertex0.y + vertex1.y + vertex2.y) / 3)
    }
    
    public func incentre() -> CGPoint {
        // TODO:
        
        return CGPoint.zero
    }
    
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
