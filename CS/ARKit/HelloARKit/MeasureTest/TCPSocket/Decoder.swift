//
//  Decoder.swift
//  MeasureTest
//
//  Created by 이충신 on 2018. 1. 28..
//  Copyright © 2018년 GGOMMI. All rights reserved.
//

import Foundation

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


