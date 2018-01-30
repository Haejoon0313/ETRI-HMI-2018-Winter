//
//  TCPSocket.swift
//  MeasureTest
//
//  Created by 이충신 on 2018. 1. 21..
//  Copyright © 2018년 GGOMMI. All rights reserved.
//

import Foundation

typealias Byte = UInt8

class TCPSocket: NSObject, StreamDelegate {
    
    var host:String?
    var port:Int?
    var inputStream: InputStream?
    var outputStream: OutputStream?
    
    func connect(host: String, port: Int) {
        self.host = host
        self.port = port
        Stream.getStreamsToHost(withName:host, port : port, inputStream: &inputStream, outputStream: &outputStream)
        
        if inputStream != nil && outputStream != nil {
            // Set delegate
            inputStream!.delegate = self
            outputStream!.delegate = self
            // Schedule(Asynchronous)
            inputStream!.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
            outputStream!.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
            
            // Open!
            print("Stream open()")
            inputStream!.open()
            outputStream!.open()
        }
    }
    
    /*
     func send(data: Data) -> Int {
     let bytesWritten = data.withUnsafeBytes { outputStream?.write($0, maxLength: data.count) }
     return bytesWritten!
     }
     
     func send(data: String) -> Int {
     let bytesWritten = outputStream?.write(data, maxLength:data.characters.count)
     return bytesWritten!
     }
     
     func send(data: [Byte]) {
     let bytesWritten = outputStream?.write(data, maxLength: data.count)
     print("bytesWritten is = \(bytesWritten!)")
     }
     */
    
    func send(_ data: [Byte], _ length: Int) -> Bool {
        var cursor = data
        var bytesRemaining = length
        
        repeat {
            let bytesWritten = outputStream?.write(cursor, maxLength: bytesRemaining)
            if bytesWritten! < 0 {
                if errno != EINTR {
                    return false
                }
            }
            else {
                cursor.removeFirst(bytesWritten!)
                bytesRemaining -= bytesWritten!
                if bytesRemaining == 0 {
                    return true
                }
            }
        } while true
        
    }
    
    func recv(buffersize: Int) -> [Byte] {
        var buffer = [UInt8](repeating :0, count : buffersize)
        inputStream?.read(&buffer, maxLength: buffersize)
        return buffer
    }
    
    func disconnect() {
        inputStream?.close()
        outputStream?.close()
    }
    
}

/*
 //Originally, This is located in TCPSocket class
    func stream(_ stream: Stream, handle eventCode: Stream.Event){
        print("event:\(eventCode)")
            if stream === inputStream {
                switch eventCode {
                    case Stream.Event.errorOccurred:
                        print("inputStream:ErrorOccurred")
                    case Stream.Event.openCompleted:
                        print("inputStream:OpenCompleted")
                    case Stream.Event.hasBytesAvailable:
                        print("inputStream:HasBytesAvailable")
                    default:    break
                }
            }
            else if stream === outputStream {
                switch eventCode {
                    case Stream.Event.errorOccurred:
                        print("outputStream:ErrorOccurred")
                    case Stream.Event.openCompleted:
                        print("outputStream:OpenCompleted")
                    case Stream.Event.hasSpaceAvailable:
                        print("outputStream:HasSpaceAvailable")
                    default:    break
                }
            }
    }
*/





