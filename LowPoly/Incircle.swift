//
//  Incircle.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/22.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

public struct Incircle {
    public let incenter: Point
    public let radius: Double
    
    public init(incenter: Point, radius: Double) {
        self.incenter = incenter
        self.radius = radius
    }
}
