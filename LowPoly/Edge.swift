//
//  Edge.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/11.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

struct Edge {
    let p0: Point
    let p1: Point
    
    init(p0: Point, p1: Point) {
        self.p0 = p0
        self.p1 = p1
    }
}

extension Edge: Equatable {
    static func ==(lhs: Edge, rhs: Edge) -> Bool {
        return lhs.p0 == rhs.p0 && lhs.p1 == rhs.p1 || lhs.p0 == rhs.p1 && lhs.p1 == rhs.p0
    }
}
