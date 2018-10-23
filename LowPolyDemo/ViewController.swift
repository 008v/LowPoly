//
//  ViewController.swift
//  LowPolyDemo
//
//  Created by WEI QIN on 2018/10/23.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import UIKit
import LowPoly

class ViewController: UIViewController {
    
    var zoomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 20.0
        zoomView = UIView(frame: view.bounds)
        scrollView.addSubview(zoomView)
        view.addSubview(scrollView)
        let imageView = UIImageView.init(frame: view.bounds)
        imageView.contentMode = .topLeft
        zoomView.addSubview(imageView)
        
        let startTime = Date()

        /* load image */
        guard let image = UIImage(contentsOfFile: Bundle.main.path(forResource: "pool", ofType: "jpg")!) else {
            return
        }
        guard let imageModel = Image.load(image: image) else {
            return
        }
        defer {
            imageModel.deallocate()
        }
        
        let time1 = Date()
        
        print("\(time1.timeIntervalSince1970 - startTime.timeIntervalSince1970) <-- load image")
        
        /* detect edges, get all points of edges*/
        var points = Sobel().edgePoints(imageModel)
        
        let time2 = Date()
        
        print("\(time2.timeIntervalSince1970 - time1.timeIntervalSince1970) <-- edge detection")
        
        /* pick out some points from the point set */
        var selectedPoints = [Point]()
        let selectRatio: Int = 30
        let selectCount = points.count / selectRatio
        for i in 0..<selectCount {
            let point = points[i * selectRatio]
            let vertex = Point(x: point.x, y: point.y)
            selectedPoints.append(vertex)
        }
        
        let time3 = Date()
        
        print("\(time3.timeIntervalSince1970 - time2.timeIntervalSince1970) <-- choose points")
        
        /* add some randomly generated points into it */
        
        /* output triangles with Delaunay Triangulation  */
        let triangles = Delaunay().triangulate(selectedPoints)
        
        let time4 = Date()
        
        print("\(time4.timeIntervalSince1970 - time3.timeIntervalSince1970) <-- triangulation")
        
        /* render on the screen */
        
        /*
         for triangle in triangles {
         let shape = CAShapeLayer()
         shape.path = triangle.toPath()
         shape.fillColor = UIColor.clear.cgColor
         shape.strokeColor = UIColor.red.cgColor
         shape.lineJoin = CAShapeLayerLineJoin.round
         shape.lineCap = CAShapeLayerLineCap.round
         shape.lineWidth = 1.0
         zoomView.layer.addSublayer(shape)
         }
         */
        
        /* draw image */
        UIGraphicsBeginImageContextWithOptions(CGSize(width: (image.cgImage?.width)!, height: (image.cgImage?.height)!), true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setAllowsAntialiasing(false)
        context.setStrokeColor(UIColor.clear.cgColor)
        context.setLineWidth(0.5)
        for (_, triangle) in triangles.enumerated()  {
            let centroid = triangle.centroid()
            guard let fillColor = imageModel.getPixelColor(x: Int(centroid.x), y: Int(centroid.y))?.cgColor else {
                return
            }
            context.setFillColor(fillColor)
            context.setStrokeColor(UIColor.yellow.cgColor)
            context.setLineWidth(0.5)
            context.move(to: triangle.p0.cgPoint())
            context.addLine(to: triangle.p1.cgPoint())
            context.addLine(to: triangle.p2.cgPoint())
            context.addLine(to: triangle.p0.cgPoint())
            context.closePath()
            context.fillPath()
        }
        guard let outputImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return
        }
        
        let time5 = Date()
        
        print("\(time5.timeIntervalSince1970 - time4.timeIntervalSince1970) <-- draw image")
        
        imageView.image = outputImage
 
        let endTime = Date()
        print("\(endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970) <-- TOTAL")
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
}
