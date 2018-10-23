//
//  Delaunay.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/11.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import UIKit

public class Delaunay: NSObject {

    public override init() { }

    fileprivate func supertriangle(_ vertices: [Point]) -> [Point] {
        
        var xmin = Double(Int32.max)
        var ymin = Double(Int32.max)
        var xmax = Double(Int32.min)
        var ymax = Double(Int32.min)
        
        for i in 0..<vertices.count {
            if vertices[i].x < xmin { xmin = vertices[i].x }
            if vertices[i].x > xmax { xmax = vertices[i].x }
            if vertices[i].y < ymin { ymin = vertices[i].y }
            if vertices[i].y > ymax { ymax = vertices[i].y }
        }
        
        let dx = xmax - xmin
        let dy = ymax - ymin
        let dmax = max(dx, dy)
        let xmid = xmin + dx * 0.5
        let ymid = ymin + dy * 0.5
        
        return [Point(x: xmid - 20 * dmax, y: ymid - dmax),
                Point(x: xmid, y: ymid + 20 * dmax),
                Point(x: xmid + 20 * dmax, y: ymid - dmax)]
    }
    
    fileprivate func circumcircle(_ i: Point, j: Point, k: Point) -> Circumcircle {
        let x1 = i.x
        let y1 = i.y
        let x2 = j.x
        let y2 = j.y
        let x3 = k.x
        let y3 = k.y
        let xc: Double
        let yc: Double
        
        let fabsy1y2 = abs(y1 - y2)
        let fabsy2y3 = abs(y2 - y3)
        
        if fabsy1y2 < Double.ulpOfOne {
            let m2 = -((x3 - x2) / (y3 - y2))
            let mx2 = (x2 + x3) / 2
            let my2 = (y2 + y3) / 2
            xc = (x2 + x1) / 2
            yc = m2 * (xc - mx2) + my2
        } else if fabsy2y3 < Double.ulpOfOne {
            let m1 = -((x2 - x1) / (y2 - y1))
            let mx1 = (x1 + x2) / 2
            let my1 = (y1 + y2) / 2
            xc = (x3 + x2) / 2
            yc = m1 * (xc - mx1) + my1
        } else {
            let m1 = -((x2 - x1) / (y2 - y1))
            let m2 = -((x3 - x2) / (y3 - y2))
            let mx1 = (x1 + x2) / 2
            let mx2 = (x2 + x3) / 2
            let my1 = (y1 + y2) / 2
            let my2 = (y2 + y3) / 2
            xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2)
            
            if fabsy1y2 > fabsy2y3 {
                yc = m1 * (xc - mx1) + my1
            } else {
                yc = m2 * (xc - mx2) + my2
            }
        }
        
        let dx = x2 - xc
        let dy = y2 - yc
        let rsqr = dx * dx + dy * dy
        
        return Circumcircle(p0: i, p1: j, p2: k, x: xc, y: yc, rsqr: rsqr)
    }
    
    fileprivate func dedup(_ edges: [Point]) -> [Point] {
        
        var e = edges
        var a: Point?, b: Point?, m: Point?, n: Point?
        
        var j = e.count
        while j > 0 {
            j -= 1
            b = j < e.count ? e[j] : nil
            j -= 1
            a = j < e.count ? e[j] : nil
            
            var i = j
            while i > 0 {
                i -= 1
                n = e[i]
                i -= 1
                m = e[i]
                
                if (a == m && b == n) || (a == n && b == m) {
                    e.removeSubrange(j...j + 1)
                    e.removeSubrange(i...i + 1)
                    break
                }
            }
        }
        
        return e
    }
    
    public func triangulate(_ vertices: [Point]) -> [Triangle] {
        
        var _vertices = Array(Set(vertices))
        
        guard _vertices.count >= 3 else {
            return [Triangle]()
        }
        
        let n = _vertices.count
        var open = [Circumcircle]()
        var completed = [Circumcircle]()
        var edges = [Point]()
        
        var indices = [Int](0..<n).sorted {  _vertices[$0].x < _vertices[$1].x }
        
        _vertices += supertriangle(_vertices)
        
        open.append(circumcircle(_vertices[n], j: _vertices[n + 1], k: _vertices[n + 2]))
        
        for i in 0..<n {
            let c = indices[i]
            
            edges.removeAll()

            for j in (0..<open.count).reversed() {
                
                let dx = _vertices[c].x - open[j].x
                
                if dx > 0 && dx * dx > open[j].rsqr {
                    completed.append(open.remove(at: j))
                    continue
                }
                
                let dy = _vertices[c].y - open[j].y
                
                if dx * dx + dy * dy - open[j].rsqr > Double.ulpOfOne {
                    continue
                }
                
                edges += [
                    open[j].p0, open[j].p1,
                    open[j].p1, open[j].p2,
                    open[j].p2, open[j].p0
                ]
                
                open.remove(at: j)
            }
            
            edges = dedup(edges)
            
            var j = edges.count
            while j > 0 {
                
                j -= 1
                let b = edges[j]
                j -= 1
                let a = edges[j]
                open.append(circumcircle(a, j: b, k: _vertices[c]))
            }
        }
        
        completed += open
        
        let ignored: Set<Point> = [_vertices[n], _vertices[n + 1], _vertices[n + 2]]
        
        let results = completed.compactMap { (circumCircle) -> Triangle? in
            
            let current: Set<Point> = [circumCircle.p0, circumCircle.p1, circumCircle.p2]
            let intersection = ignored.intersection(current)
            if intersection.count > 0 {
                return nil
            }
            
            return Triangle(p0: circumCircle.p0, p1: circumCircle.p1, p2: circumCircle.p2)
        }
        
        return results
    }
}
