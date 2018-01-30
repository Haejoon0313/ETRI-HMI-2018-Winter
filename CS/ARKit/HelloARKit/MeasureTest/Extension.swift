//
//  Extension.swift
//  MeasureTest
//
//  Created by Dev on 2018. 1. 29..
//  Copyright © 2018년 Dev. All rights reserved.
//

import Foundation
import  UIKit

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}

extension UIImage {
    func pixelData() -> [UInt8]? {
        
        var r: [Byte] = []
        var g: [Byte] = []
        var b: [Byte] = []
        var t: [Byte] = []
        
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8,bytesPerRow: 4 * Int(size.width),
                                space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        for i in 0..<Int(dataSize)/4{
            r.append(pixelData[4*i])
            g.append(pixelData[4*i+1])
            b.append(pixelData[4*i+2])
        }
        
        for i in 0..<Int(dataSize)/4{
            t.append(b[i])
            t.append(g[i])
            t.append(r[i])
        }
        
        return t
    }
}
