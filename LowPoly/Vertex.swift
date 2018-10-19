//
//  Vertex.swift
//  DelaunayTriangulation
//
//  Created by WEI QIN on 2018/10/11.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import UIKit

public struct Vertex {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

extension Vertex: Hashable {
    public var hashValue: Int {
        var seed = UInt(0)
        hash_combine(seed: &seed, value: UInt(bitPattern: x.hashValue))
        hash_combine(seed: &seed, value: UInt(bitPattern: y.hashValue))
        return Int(bitPattern: seed)
    }
}

extension Vertex: Equatable {
    static public func ==(lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension Vertex {
    public func cgPoint() -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    static func random(maxX: Double, maxY: Double) -> Vertex {
        let x = Double(arc4random_uniform(UInt32(maxX)))
        let y = Double(arc4random_uniform(UInt32(maxY)))
        return Vertex(x: x, y: y)
    }
}
