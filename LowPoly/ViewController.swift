//
//  ViewController.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/18.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import UIKit

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

        /* load image */
        guard let image = UIImage(contentsOfFile: Bundle.main.path(forResource: "skull", ofType: "jpg")!) else {
            return
        }
        
        /* detect edges */
        let highlightedImage = Sobel.sobelEdgeDetection(image: image)
        
        let imageView = UIImageView.init(frame: view.bounds)
        imageView.contentMode = .topLeft
        imageView.image = highlightedImage
        zoomView.addSubview(imageView)
        
        /* get all points of edges */
        var points = Sobel.pointArray(highlightedEdgesImage: highlightedImage!)
        
        /* pick out some points from the point set */
        var vertices = [Vertex]()
        let pickoutRatio: Int = 50
        let pickoutCount = points.count / pickoutRatio
        for i in 0..<pickoutCount {
            let point = points[i * pickoutRatio]
            let vertex = Vertex(x: Double(point.x), y: Double(point.y))
            vertices.append(vertex)
        }
        
        /* add some randomly generated points into it */
        let width = image.cgImage?.width ?? 0
        let height = image.cgImage?.height ?? 0
        let addCount = pickoutCount
        for i in 0..<addCount {
            let vertex = Vertex.random(maxX: Double(width), maxY: Double(height))
            vertices.append(vertex)
        }
        
        /* output triangles with Delaunay Triangulation  */
        let triangles = Delaunay().triangulate(vertices)
        
        /* render on the screen */
        
        /*/
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
            guard let fillColor = image.color(x: Int(centroid.x), y: Int(centroid.y))?.cgColor else {
                return
            }
            context.setFillColor(fillColor)
            context.setStrokeColor(UIColor.yellow.cgColor)
            context.setLineWidth(0.5)
            context.move(to: triangle.vertex0.cgPoint())
            context.addLine(to: triangle.vertex1.cgPoint())
            context.addLine(to: triangle.vertex2.cgPoint())
            context.addLine(to: triangle.vertex0.cgPoint())
            context.closePath()
            context.fillPath()
        }
        guard let outputImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return
        }
        imageView.image = outputImage
        
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
}

extension UIImage {
    func color(x: Int, y: Int) -> UIColor? {
        guard let cgImage = cgImage else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        if x < 0 || x >= width || y < 0 || y >= height {
            return nil
        }
        
        struct Holder {
            static var data: UnsafePointer<UInt8>? = nil
        }
        
        if Holder.data == nil {
            guard let pixelData = cgImage.dataProvider?.data else {
                return nil
            }
            Holder.data = CFDataGetBytePtr(pixelData)
        }
        
        let pixelInfo: Int = ((width * y) + x) * 4
        
        guard let data = Holder.data else {
            return nil
        }
        
        let r = Double(data[pixelInfo]) / 255.0
        let g = Double(data[pixelInfo + 1]) / 255.0
        let b = Double(data[pixelInfo + 2]) / 255.0
        let a = Double(data[pixelInfo + 3]) / 255.0
        
        return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
}

