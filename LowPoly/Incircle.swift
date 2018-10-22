//
//  Incircle.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/22.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import UIKit

public struct Incircle {
    public let incenter: Vertex
    public let radius: Double
    
    public init(incenter: Vertex, radius: Double) {
        self.incenter = incenter
        self.radius = radius
    }
}
