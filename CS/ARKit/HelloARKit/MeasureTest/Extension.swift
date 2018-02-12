//
//  Extension.swift
//  MeasureTest
//
//  Created by Dev on 2018. 1. 29..
//  Copyright © 2018년 Dev. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import UIKit


extension ViewController: ARSessionObserver {
    
    func sessionWasInterrupted(_ session: ARSession) {
        showToast("Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        showToast("Session failed: \(error.localizedDescription)")
        resetTracking()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        var message: String? = nil
        
        switch camera.trackingState {
            case .notAvailable:
                message = "트래킹이 불가능 합니다."
            case .limited(.initializing):
                message = "AR Session 초기화 중"
            case .limited(.excessiveMotion):
                message = "모션이 지나칩니다."
            case .limited(.insufficientFeatures):
                message = "추적할 평면공간 정보가 충분하지 않습니다."
            case .normal:
                message = "수평면 탐색을 위해 움직여 주세요."
        }
        
        message != nil ? showToast(message!) : hideToast()
    }
    
    
}

extension ViewController {
    
    func hideMeasureElement(_ bool: Bool){
        stackView.isHidden = bool
        measureAim.isHidden = bool
        rulerButton.isHidden = bool
    }
    
    func showSlideMenu(){
        sideMenuConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
    }
    
    func hideSlideMenu(){
        sideMenuConstraint.constant = -140
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
    }
    
    func showToast(_ text: String) {
        label.text = text
        guard toast.alpha == 0 else {
            return
        }
        
        toast.layer.masksToBounds = true
        toast.layer.cornerRadius = 7.5
        
        UIView.animate(withDuration: 0.25, animations: {
            self.toast.alpha = 1
            self.toast.frame = self.toast.frame.insetBy(dx: -5, dy: -5)
        })
        
    }
    
    func hideToast() {
        UIView.animate(withDuration: 0.25, animations: {
            self.toast.alpha = 0
            self.toast.frame = self.toast.frame.insetBy(dx: 5, dy: 5)
        })
    }
}



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
    
    func averageColor() -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        if let cgImage = self.cgImage, let averageFilter = CIFilter(name: "CIAreaAverage") {
            let ciImage = CIImage(cgImage: cgImage)
            let extent = ciImage.extent
            let ciExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            averageFilter.setValue(ciImage, forKey: kCIInputImageKey)
            averageFilter.setValue(ciExtent, forKey: kCIInputExtentKey)
            if let outputImage = averageFilter.outputImage {
                let context = CIContext(options: nil)
                var bitmap = [UInt8](repeating: 0, count: 4)
                context.render(outputImage,
                               toBitmap: &bitmap,
                               rowBytes: 4,
                               bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                               format: kCIFormatRGBA8,
                               colorSpace: CGColorSpaceCreateDeviceRGB())
                
                return (red: CGFloat(bitmap[0]) / 255.0,
                        green: CGFloat(bitmap[1]) / 255.0,
                        blue: CGFloat(bitmap[2]) / 255.0)
            }
        }
        return nil
    }
    
}

extension ARSCNView {
    func averageColorFromEnvironment(at screenPos: SCNVector3) -> SCNVector3 {
        var colorVector = SCNVector3()
        
        // Take screenshot of the scene, without the content
        scene.rootNode.isHidden = true
        let screenshot: UIImage = snapshot()
        scene.rootNode.isHidden = false
        // Use a patch from the specified screen position
        let scale = UIScreen.main.scale
        let patchSize: CGFloat = 100 * scale
        let screenPoint = CGPoint(x: (CGFloat(screenPos.x) - patchSize / 2) * scale,
                                  y: (CGFloat(screenPos.y) - patchSize / 2) * scale)
        let cropRect = CGRect(origin: screenPoint, size: CGSize(width: patchSize, height: patchSize))
        if let croppedCGImage = screenshot.cgImage?.cropping(to: cropRect) {
            let image = UIImage(cgImage: croppedCGImage)
            if let avgColor = image.averageColor() {
                colorVector = SCNVector3(avgColor.red, avgColor.green, avgColor.blue)
            }
        }
        return colorVector
    }
}

extension SCNAnimation {
    static func fromFile(named name: String, inDirectory: String ) -> SCNAnimation? {
        let animScene = SCNScene(named: name, inDirectory: inDirectory)
        var animation: SCNAnimation?
        animScene?.rootNode.enumerateChildNodes({ (child, stop) in
            if !child.animationKeys.isEmpty {
                let player = child.animationPlayer(forKey: child.animationKeys[0])
                animation = player?.animation
                stop.initialize(to: true)
            }
        })
        
        animation?.keyPath = name
        
        return animation
    }
}

extension SCNVector3: Equatable {
    
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    func distance(from vector: SCNVector3) -> Float {
        let distanceX = self.x - vector.x
        let distanceY = self.y - vector.y
        let distanceZ = self.z - vector.z
        
        return sqrtf( (distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
    }
    
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}

extension ARSCNView {
    func realWorldVector(screenPos: CGPoint) -> SCNVector3? {
        let planeTestResults = self.hitTest(screenPos, types: [.existingPlaneUsingExtent])
        if let result = planeTestResults.first {
            return SCNVector3.positionFromTransform(result.worldTransform)
        }
        return nil
    }
}

extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
     */
    var translation: float3 {
        let translation = columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension Collection where Iterator.Element == Float, IndexDistance == Int {
    /// Return the mean of a list of Floats. Used with `recentVirtualObjectDistances`.
    var average: Float? {
        guard !isEmpty else {
            return nil
        }
        
        let sum = reduce(Float(0)) { current, next -> Float in
            return current + next
        }
        
        return sum / Float(count)
    }
}


