//
//  Image.swift
//  LowPoly
//
//  Created by WEI QIN on 2018/10/23.
//  Copyright © 2018 WEI QIN. All rights reserved.
//

import UIKit

public class Image: NSObject {
    
    public var width: Int = 0
    public var height: Int = 0
    public var rawData: UnsafeMutableRawPointer?
    
    fileprivate override init() {
        super.init()
    }
    
    public init(width: Int, height: Int, rawData: UnsafeMutableRawPointer?) {
        self.width = width
        self.height = height
        self.rawData = rawData
        super.init()
    }
    
    public static func load(image: UIImage) -> Image? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        guard let rawData = calloc(height * width * 4, MemoryLayout<CUnsignedChar>.size) else {
            return nil
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        guard let context = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return Image(width: width, height: height, rawData: rawData)
    }
    
    public func deallocate() {
        if rawData != nil {
            rawData?.deallocate()
            rawData = nil
        }
    }
    
    public func getPixelColor(x: Int, y: Int) -> UIColor? {
        guard x >= 0, x < width, y >= 0, y < height, let rawData = self.rawData else {
            return nil
        }
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bytesIndex = y * bytesPerRow + x * bytesPerPixel
        let red = CGFloat(rawData.load(fromByteOffset: bytesIndex, as: UInt8.self)) / 255.0
        let green = CGFloat(rawData.load(fromByteOffset: bytesIndex|1, as: UInt8.self)) / 255.0
        let blue = CGFloat(rawData.load(fromByteOffset: bytesIndex|2, as: UInt8.self)) / 255.0
        let alpha = CGFloat(rawData.load(fromByteOffset: bytesIndex|3, as: UInt8.self)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public func getGray(x: Int, y: Int) -> Double {
        guard x >= 0, x < width, y >= 0, y < height, let rawData = self.rawData else {
            return 0
        }
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bytesIndex = y * bytesPerRow + x * bytesPerPixel
        let red = rawData.load(fromByteOffset: bytesIndex, as: UInt8.self)
        let green = rawData.load(fromByteOffset: bytesIndex|1, as: UInt8.self)
        let blue = rawData.load(fromByteOffset: bytesIndex|2, as: UInt8.self)
        return 0.30 * Double(red) + 0.59 * Double(green) + 0.11 * Double(blue)
    }
    
}
