//
//  Edge.swift
//  DelaunayTriangulation
//
//  Created by WEI QIN on 2018/10/11.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

struct Edge {
    let vertex0: Vertex
    let vertex1: Vertex
    
    init(vertex0: Vertex, vertex1: Vertex) {
        self.vertex0 = vertex0
        self.vertex1 = vertex1
    }
}

extension Edge: Equatable {
    static func ==(lhs: Edge, rhs: Edge) -> Bool {
        return lhs.vertex0 == rhs.vertex0 && lhs.vertex1 == rhs.vertex1 || lhs.vertex0 == rhs.vertex1 && lhs.vertex1 == rhs.vertex0
    }
}
