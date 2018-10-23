//
//  Sobel.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/12.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import simd
import UIKit

public class Sobel: NSObject {
    
    fileprivate let kernelX = float3x3(float3(1, 2, 1), float3(0, 0, 0), float3(-1, -2, -1))
    fileprivate let kernelY = float3x3(float3(1, 0, -1), float3(2, 0, -2), float3(1, 0, -1))
    
    public func edgeDetection(image: UIImage) -> UIImage? {
        
        guard let inputImage = Image.load(image: image) else {
            return nil
        }
        
        defer {
            inputImage.deallocate()
        }
        
        var meanGrayValue: Double = 0
        
        for y in 0..<inputImage.height {
            for x in 0..<inputImage.width {
                meanGrayValue = meanGrayValue + inputImage.getGray(x: x, y: y)
            }
        }
        
        meanGrayValue = meanGrayValue / Double(inputImage.width * inputImage.height)
        
        guard let rawData = calloc(inputImage.height * inputImage.width * 4, MemoryLayout<CUnsignedChar>.size) else {
            return nil
        }
        
        defer {
            rawData.deallocate()
        }
        
        for y in 0..<inputImage.height {
            for x in 0..<inputImage.width {
                let gx = (
                    Double(kernelX.columns.0.x) * inputImage.getGray(x: x - 1, y: y - 1) +
                    Double(kernelX.columns.0.y) * inputImage.getGray(x: x - 1, y: y) +
                    Double(kernelX.columns.0.z) * inputImage.getGray(x: x - 1, y: y + 1) +
                    Double(kernelX.columns.1.x) * inputImage.getGray(x: x, y: y - 1) +
                    Double(kernelX.columns.1.y) * inputImage.getGray(x: x, y: y) +
                    Double(kernelX.columns.1.z) * inputImage.getGray(x: x, y: y + 1) +
                    Double(kernelX.columns.2.x) * inputImage.getGray(x: x + 1, y: y - 1) +
                    Double(kernelX.columns.2.y) * inputImage.getGray(x: x + 1, y: y) +
                    Double(kernelX.columns.2.z) * inputImage.getGray(x: x + 1, y: y + 1)
                    )
                let gy = (
                    Double(kernelY.columns.0.x) * inputImage.getGray(x: x - 1, y: y - 1) +
                    Double(kernelY.columns.0.y) * inputImage.getGray(x: x - 1, y: y) +
                    Double(kernelY.columns.0.z) * inputImage.getGray(x: x - 1, y: y + 1) +
                    Double(kernelY.columns.1.x) * inputImage.getGray(x: x, y: y - 1) +
                    Double(kernelY.columns.1.y) * inputImage.getGray(x: x, y: y) +
                    Double(kernelY.columns.1.z) * inputImage.getGray(x: x, y: y + 1) +
                    Double(kernelY.columns.2.x) * inputImage.getGray(x: x + 1, y: y - 1) +
                    Double(kernelY.columns.2.y) * inputImage.getGray(x: x + 1, y: y) +
                    Double(kernelY.columns.2.z) * inputImage.getGray(x: x + 1, y: y + 1)
                    )
                let g = sqrt(pow(gx, 2) + pow(gy, 2))
                
                let bytesIndex = (inputImage.width * y + x) * 4
                
                if g > meanGrayValue {
                    rawData.storeBytes(of: UInt8(255), toByteOffset: bytesIndex|0, as: UInt8.self)
                    rawData.storeBytes(of: UInt8(255), toByteOffset: bytesIndex|1, as: UInt8.self)
                    rawData.storeBytes(of: UInt8(255), toByteOffset: bytesIndex|2, as: UInt8.self)
                    rawData.storeBytes(of: UInt8(255), toByteOffset: bytesIndex|3, as: UInt8.self)
                }else {
                    rawData.storeBytes(of: UInt8(0), toByteOffset: bytesIndex|0, as: UInt8.self)
                    rawData.storeBytes(of: UInt8(0), toByteOffset: bytesIndex|1, as: UInt8.self)
                    rawData.storeBytes(of: UInt8(0), toByteOffset: bytesIndex|2, as: UInt8.self)
                    rawData.storeBytes(of: UInt8(255), toByteOffset: bytesIndex|3, as: UInt8.self)
                }
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * inputImage.width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: rawData,
                                      width: inputImage.width,
                                      height: inputImage.height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
                                        return nil
        }
        
        guard let makeImage = context.makeImage() else {
            return nil
        }
        
        let result = UIImage(cgImage: makeImage)
    
        return result
    }
    
    public func points(highlightedEdgesImage: UIImage) -> [Point] {
        
        var points = [Point]()

        guard let inputImage = Image.load(image: highlightedEdgesImage) else {
            return points
        }
        
        defer {
            inputImage.deallocate()
        }
        
        guard let rawData = inputImage.rawData else {
            return points
        }
        
        for y in 0..<inputImage.height {
            for x in 0..<inputImage.width {
                let pixelInfo: Int = ((inputImage.width * y) + x) * 4
                let r = rawData.load(fromByteOffset: pixelInfo|0, as: UInt8.self)
                let g = rawData.load(fromByteOffset: pixelInfo|1, as: UInt8.self)
                let b = rawData.load(fromByteOffset: pixelInfo|2, as: UInt8.self)
                
                if r == 255 && g == 255 && b == 255 {
                    points.append(Point(x: x, y: y))
                }
            }
        }
        
        return points
    }
    
    public func edgePoints(_ image: Image) -> [Point] {
        
        var points = [Point]()
        
        var meanGrayValue: Double = 0
        
        for y in 0..<image.height {
            for x in 0..<image.width {
                meanGrayValue = meanGrayValue + image.getGray(x: x, y: y)
            }
        }
        
        meanGrayValue = meanGrayValue / Double(image.width * image.height)
        
        for y in 0..<image.height {
            for x in 0..<image.width {
                let gx = (
                        Double(kernelX.columns.0.x) * image.getGray(x: x - 1, y: y - 1) +
                        Double(kernelX.columns.0.y) * image.getGray(x: x - 1, y: y) +
                        Double(kernelX.columns.0.z) * image.getGray(x: x - 1, y: y + 1) +
                        Double(kernelX.columns.1.x) * image.getGray(x: x, y: y - 1) +
                        Double(kernelX.columns.1.y) * image.getGray(x: x, y: y) +
                        Double(kernelX.columns.1.z) * image.getGray(x: x, y: y + 1) +
                        Double(kernelX.columns.2.x) * image.getGray(x: x + 1, y: y - 1) +
                        Double(kernelX.columns.2.y) * image.getGray(x: x + 1, y: y) +
                        Double(kernelX.columns.2.z) * image.getGray(x: x + 1, y: y + 1)
                )
                let gy = (
                        Double(kernelY.columns.0.x) * image.getGray(x: x - 1, y: y - 1) +
                        Double(kernelY.columns.0.y) * image.getGray(x: x - 1, y: y) +
                        Double(kernelY.columns.0.z) * image.getGray(x: x - 1, y: y + 1) +
                        Double(kernelY.columns.1.x) * image.getGray(x: x, y: y - 1) +
                        Double(kernelY.columns.1.y) * image.getGray(x: x, y: y) +
                        Double(kernelY.columns.1.z) * image.getGray(x: x, y: y + 1) +
                        Double(kernelY.columns.2.x) * image.getGray(x: x + 1, y: y - 1) +
                        Double(kernelY.columns.2.y) * image.getGray(x: x + 1, y: y) +
                        Double(kernelY.columns.2.z) * image.getGray(x: x + 1, y: y + 1)
                )
                let g = sqrt(pow(gx, 2) + pow(gy, 2))
                                
                if g > meanGrayValue {
                    points.append(Point(x: x, y: y))
                }
            }
        }
        
        return points
    }
}
