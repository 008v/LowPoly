//
//  Point.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/11.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import CoreGraphics

public struct Point {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public init(x: Int, y: Int) {
        self.x = Double(x)
        self.y = Double(y)
    }
}

extension Point: Hashable {
    public var hashValue: Int {
        var seed = UInt(0)
        hash_combine(seed: &seed, value: UInt(bitPattern: x.hashValue))
        hash_combine(seed: &seed, value: UInt(bitPattern: y.hashValue))
        return Int(bitPattern: seed)
    }
}

extension Point: Equatable {
    static public func ==(lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension Point {
    public func cgPoint() -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    public func distance(_ point: Point) -> Double {
        return sqrt(pow((x - point.x), 2) + pow((y - point.y), 2))
    }
    
    public func isInRect(_ width: Double, height: Double) -> Bool {
        return !(x < 0 || x >= width || y < 0 || y >= height)
    }
    
    public func isNaN() -> Bool {
        return x.isNaN || y.isNaN
    }
    
    public static var nan: Point {
        get {
            return Point(x: Double.nan, y: Double.nan)
        }
    }
}
