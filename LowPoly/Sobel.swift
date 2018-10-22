//
//  Sobel.swift
//  Sobel
//
//  Created by WEI QIN on 2018/10/12.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import simd
import UIKit

class Sobel: NSObject {
    
    static func sobelEdgeDetection(image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var meanGrayValue: Double = 0
        for y in 0..<height {
            for x in 0..<width {
                meanGrayValue = meanGrayValue + getGray(image: image, x: x, y: y)
            }
        }
        meanGrayValue = meanGrayValue / Double(width) / Double(height)
        
        let kernelX = float3x3(float3(1, 2, 1),
                               float3(0, 0, 0),
                               float3(-1, -2, -1))
        let kernelY = float3x3(float3(1, 0, -1),
                               float3(2, 0, -2),
                               float3(1, 0, -1))
        
        guard let pixelData = cgImage.dataProvider?.data else {
            return nil
        }
        guard let copyData = CFDataCreateCopy(nil, pixelData) else {
            return nil
        }
        guard let outputData = UnsafeMutablePointer<UInt8>(mutating: CFDataGetBytePtr(copyData)) else {
            return nil
        }
        
        for y in 0..<height {
            for x in 0..<width {
                let gx = (
                    Double(kernelX.columns.0.x) * getGray(image: image, x: x - 1, y: y - 1) +
                    Double(kernelX.columns.0.y) * getGray(image: image, x: x - 1, y: y) +
                    Double(kernelX.columns.0.z) * getGray(image: image, x: x - 1, y: y + 1) +
                    Double(kernelX.columns.1.x) * getGray(image: image, x: x, y: y - 1) +
                    Double(kernelX.columns.1.y) * getGray(image: image, x: x, y: y) +
                    Double(kernelX.columns.1.z) * getGray(image: image, x: x, y: y + 1) +
                    Double(kernelX.columns.2.x) * getGray(image: image, x: x + 1, y: y - 1) +
                    Double(kernelX.columns.2.y) * getGray(image: image, x: x + 1, y: y) +
                    Double(kernelX.columns.2.z) * getGray(image: image, x: x + 1, y: y + 1)
                    )
                let gy = (
                    Double(kernelY.columns.0.x) * getGray(image: image, x: x - 1, y: y - 1) +
                    Double(kernelY.columns.0.y) * getGray(image: image, x: x - 1, y: y) +
                    Double(kernelY.columns.0.z) * getGray(image: image, x: x - 1, y: y + 1) +
                    Double(kernelY.columns.1.x) * getGray(image: image, x: x, y: y - 1) +
                    Double(kernelY.columns.1.y) * getGray(image: image, x: x, y: y) +
                    Double(kernelY.columns.1.z) * getGray(image: image, x: x, y: y + 1) +
                    Double(kernelY.columns.2.x) * getGray(image: image, x: x + 1, y: y - 1) +
                    Double(kernelY.columns.2.y) * getGray(image: image, x: x + 1, y: y) +
                    Double(kernelY.columns.2.z) * getGray(image: image, x: x + 1, y: y + 1)
                    )
                let g = sqrt(pow(gx, 2) + pow(gy, 2))
                
                let bytesIndex = (width * y + x) * 4
                
                if g > meanGrayValue {
                    outputData[bytesIndex] = 255
                    outputData[bytesIndex + 1] = 255
                    outputData[bytesIndex + 2] = 255
                    outputData[bytesIndex + 3] = 255
                }else {
                    outputData[bytesIndex] = 0
                    outputData[bytesIndex + 1] = 0
                    outputData[bytesIndex + 2] = 0
                    outputData[bytesIndex + 3] = 255
                }
            }
        }
        
        guard let context = CGContext(data: outputData,
                                      width: cgImage.width,
                                      height: cgImage.height,
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: cgImage.bytesPerRow,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
                                        return nil
        }
        guard let makeImage = context.makeImage() else {
            return nil
        }
        let result = UIImage(cgImage: makeImage)
    
        return result
    }
    
    static func pointArray(highlightedEdgesImage: UIImage) -> [CGPoint] {
        
        var points = [CGPoint]()

        guard let cgImage = highlightedEdgesImage.cgImage else {
            return points
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        guard let pixelData = cgImage.dataProvider?.data else {
            return points
        }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelInfo: Int = ((width * y) + x) * 4
                let r = data[pixelInfo]
                let g = data[pixelInfo + 1]
                let b = data[pixelInfo + 2]
                
                if r == 255 && g == 255 && b == 255 {
                    points.append(CGPoint(x: x, y: y))
                }
            }
        }
        
        return points
    }
    
    static func getGray(image: UIImage, x: Int, y: Int) -> Double {
        
        guard let cgImage = image.cgImage else {
            return 0
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        if x < 0 || x >= width || y < 0 || y >= height {
            return 0
        }
                
        struct Holder {
            static var data: UnsafePointer<UInt8>? = nil
        }

        if Holder.data == nil {
            guard let pixelData = cgImage.dataProvider?.data else {
                return 0
            }
            Holder.data = CFDataGetBytePtr(pixelData)
        }
        
        let pixelInfo: Int = ((width * y) + x) * 4
        
        guard let data = Holder.data else {
            return 0
        }
        
        let r = data[pixelInfo]
        let g = data[pixelInfo + 1]
        let b = data[pixelInfo + 2]
        
        return 0.30 * Double(r) + 0.59 * Double(g) + 0.11 * Double(b)
    }
}
