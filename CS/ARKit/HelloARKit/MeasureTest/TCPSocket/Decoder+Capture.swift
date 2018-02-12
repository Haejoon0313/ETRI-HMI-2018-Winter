//
//  Decoder.swift
//  MeasureTest
//
//  Created by 이충신 on 2018. 1. 28..
//  Copyright © 2018년 GGOMMI. All rights reserved.
//

import Foundation
import SceneKit

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

extension ViewController {
    
    @IBAction func capture(_ sender: Any) {
    
        let captureImage:UIImage = self.sceneView.snapshot()
        let imageArray: [Byte] = captureImage.pixelData()!
        UIImageWriteToSavedPhotosAlbum(captureImage, nil, nil, nil)
        
        var mms: [Byte] = [Byte]("MMS".utf8)
        let mme: [Byte] = [Byte]("MME".utf8)
        
        mms.append(contentsOf: imageArray)
        mms.append(contentsOf: mme)
        
        imageNumb += 1
        socket.send(mms, mms.count)
        
        let response = socket.recv(buffersize: 4096)
        
        //1) MMS: 3Byte
        let mmschecked = stringDecoder(index: 0,length: 3,received: response)
        
        if mmschecked == "MMS" {
            
            print("<ImageData Numb[\(imageNumb)]>")
            
            //2) NumbOfObj: 4Byte(UInt32)
            let numOfObj = Int(intDecoder(index: 3, received: response))
            print("Numb of Objectlist = \(numOfObj)")
            
            if numOfObj != 0 {
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
            }
                
            else {print("The number of Object is 0!"); return}
            
            //8) MME: 3Byte
            let mmechecked = stringDecoder(index: 64+(57*(numOfObj-1)), length: 3, received: response)
            if mmechecked == "MME" {print("MME is Checked")}
        }
    }
}


