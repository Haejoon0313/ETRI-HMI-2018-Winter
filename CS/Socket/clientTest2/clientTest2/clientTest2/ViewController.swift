//
//  ViewController.swift
//  clientTest2
//
//  Created by 이충신 on 2018. 1. 21..
//  Copyright © 2018년 GGOMMI. All rights reserved.
//

import UIKit
import ARKit

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

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    let host = "129.254.87.77"
    let port = 8020
    let socket = TcpSocket()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.sceneView.showsStatistics = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func ConnectButton(_ sender: Any) {
        socket.connect(host: host, port: port)
    }
    
    @IBAction func sendButton(_ sender: Any) {
        
        let captureImage:UIImage = self.sceneView.snapshot()
        var imageArray: [Byte] = captureImage.pixelData()!
        
        var mms: [Byte] = [Byte]("MMS".utf8)
        let mme: [Byte] = [Byte]("MME".utf8)
        
        mms.append(contentsOf: imageArray)
        mms.append(contentsOf: mme)
        
        print("This is image Count = \(imageArray.count)")
        
        socket.send(mms, mms.count)
        
        /*
         //This is for Test
         var test_array: [Byte] = []
         let zero = [Byte](repeating: 0 , count:750*3)
         let full = [Byte](repeating: 255, count:750*3)
         
         for i in 0..<1334 {
         if(i%2 == 0){test_array.append(contentsOf: zero)}
         else {test_array.append(contentsOf: full)}
         }
         mms.append(contentsOf: test_array)
         */
        
        let response = socket.recv(buffersize: 4096)
        
        //Decoding Part
        //[Byte] -> String
        func stringDecoder(index: Int ,length: Int, received data: [Byte]) -> String? {
            var stringarray: [Byte] = []
            for i in index..<index+length {
                stringarray.append(data[i])
            }
            return String(bytes: stringarray, encoding: .ascii)
        }
        //[Byte] -> Int
        func intDecoder(index: Int ,received data: [Byte]) -> Int32 {
            var intarray : [Byte] = []
            for i in index...index+3{
                intarray.append(data[i])
            }
            
            var value : Int32 = 0
            let nsdata = NSData(bytes: intarray, length: 4)
            nsdata.getBytes(&value, length: 4)
            return value
        }
        //[Byte] -> Float
        func floatDecoder(start index: Int, count number: Int, received data: [Byte]) -> [Float]?{
            var floatarray: [Byte] = []
            for i in index..<index+(4*number)   //response index 8~43까지 요소르 0~35로 재 배열.
            {
                floatarray.append(data[i])
            }
            var rot = [Float](repeating:0.0, count:number)
            for i in 0..<number{
                var rotarray:[Byte] = []
                for j in 4*i..<(4*i)+4{
                    rotarray.append(floatarray[j])
                }
                memcpy(&rot[i], rotarray, 4)
            }
            return rot
        }
        
        //1) MMS: 3Byte
        //2) NumbOfObj: 4Byte(UInt32)
        //-----------------------------
        //                  |3) ObjId: 1Byte(UInt8)
        //                  |4) RMat: 4Byte * 9 : 36Byte (Float)
        // numbOfObj   *    |5) Tvec: 4Byte * 3 : 12Byte (Float)
        //                  |6) Center_x: 4Byte (UInt32)
        //                  |7) Center_Y: 4Byte (UInt32)
        //                  |8) MME: 3Byte
        //-----------------------------
        //9) MME: 3Byte
        
        //1) MMS: 3Byte
        let mmschecked = stringDecoder(index: 0,length: 3,received: response)
        
        if mmschecked == "MMS" {
            
            print("MMS IS Chekced!")
            
            //2) NumbOfObj: 4Byte(UInt32)
            let numOfObj = Int(intDecoder(index: 3, received: response))
            print("Numb of Objectlist = \(numOfObj)\n")
            
            for iObj in 0..<numOfObj {
                
                //3) ObjId: 1byte(UInt8)
                if let id = stringDecoder(index: 7+(57*iObj), length: 1, received: response){
                    print("ID[\(iObj)] = " + id)
                }
                
                //4) RMat: 4byte * 9 : 36byte (Float)
                if let rot: [Float] = floatDecoder(start: 8+(57*iObj), count: 9, received: response){
                    print("<Rotation Information>")
                    for i in 0..<9 { print(rot[i]) }
                }
                
                //5) Tvec: 4byte * 3 : 12byte (Float)
                if let trn: [Float] = floatDecoder(start: 44+(57*iObj), count: 3, received: response){
                    print("<Trn Information>")
                    for i in 0..<3 { print(trn[i]) }
                }
                
                //6) 7) x_center, y_center: 4byte * 2 : 8byte (UInt32)
                print("<X,Y Information>")
                let x_center = intDecoder(index: 56+(57*iObj), received: response)
                print("X: \(x_center)")
                let y_center = intDecoder(index: 60+(57*iObj), received: response)
                print("Y: \(y_center)")
                
            }
            
            //8) MME: 3Byte
            let mmechecked = stringDecoder(index: 64+(57*(numOfObj-1)), length: 3, received: response)
            if mmechecked == "MME" {print("MME is Checked")}
            
        }
        
        //socket.disconnect()
        
    }
    
    
}

