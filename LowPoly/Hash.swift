//
//  Hash.swift
//  DelaunayTriangulation
//
//  Created by WEI QIN on 2018/10/12.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

func hash_combine(seed: inout UInt, value: UInt) {
    let tmp = value &+ 0x9e3779b9 &+ (seed << 6) &+ (seed >> 2)
    seed ^= tmp
}
