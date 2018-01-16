//
//  ViewController.swift
//  ClientTest
//
//  Created by Dev on 2018. 1. 12..
//  Copyright © 2018년 Dev. All rights reserved.
//

import UIKit
import ARKit
import Photos

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    let host = "127.0.0.1"
    let port = 8010
    var client: TCPClient?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = TCPClient(address: host, port: Int32(port)) //make client socket
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.sceneView.showsStatistics = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
      
        let captureImage:UIImage = self.sceneView.snapshot()
        //UIImageWriteToSavedPhotosAlbum(captureImage, nil, nil, nil)  //save photos at album (must add photo library addition in Info.plist)
    
        //change UIImage to binary data
        let imageData: NSData = UIImageJPEGRepresentation(captureImage, 0)! as NSData
        
        let AR_IMG_WIDTH = Int(captureImage.size.width) //750
        let AR_IMG_HEIGHT = Int(captureImage.size.height) //1334
        let AR_BUFFER_SIZE = AR_IMG_WIDTH * AR_IMG_HEIGHT * 3 + 6 //3001506 , 3(R,G,B),6 (MMS+MME)
        
        print("size of imageData 750 * 1334 * 3 : \(imageData.length)")
        
       //NSData to [Byte]
        var mms: [Byte] = [Byte]("MMS".utf8) // 3Byte
        let mme: [Byte] = [Byte]("MME".utf8) // 3Byte
        var copyArray = [Byte](repeating: 0, count: imageData.length)
        
        imageData.getBytes(&copyArray, length: imageData.length)
        mms.append(contentsOf: copyArray)
        mms.append(contentsOf: mme)
        
        print("size of send byte array = \(mms.count)")
        
        //try client connecting ...
        guard let client = client else { return }
        
        switch client.connect(timeout: 10) {
                case .success:
                    print("Connected to host \(client.address)")
                    if let response = sendRequest(string: "GET / HTTP/1.0\n\n", using: client, databuffer: mms) {
                        print("Response: \(response)")
                    }
                case .failure(let error):
                    print(String(describing: error))
            }
    }
    
    private func sendRequest(string: String, using client: TCPClient, databuffer: [Byte]) -> String? {
        
        print("Sending data ... ")
        
        //send [Byte] Data
        switch client.send(data: databuffer) {
            case .success:
              return readResponse(from: client)
            case .failure(let error):
                print(String(describing: error))
                return nil
        }
        /* Send String Data
        switch client.send(string: string) {
            case .success:
                return readResponse(from: client)
            case .failure(let error):
                print(String(describing: error))
                return nil
        }
        */
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        
        guard let response = client.read(4096) else { return nil }
        
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
    
        var data_one_obj1 : [Byte] = [0]
        
        //2) NumbOfObj: 4Byte(UInt32)
        for idx in 3..<7 {
            data_one_obj1.append(response[idx])
        }
            data_one_obj1.removeFirst()
        
        let data = NSData(bytes: data_one_obj1, length: 4)
        var num_Objs: UInt32 = 0
        data.getBytes(&num_Objs, length: 4)
        num_Objs = UInt32(bigEndian: num_Objs) //change to Big Endian(Swift default: LittleEndian)
        print("Number of Object = \(num_Objs)")
        
        //let num_Obj = Int(num_Objs) //32bit -> 64bit(Origin Int in Swift)

        for iObj in 0..<Int(num_Objs) {
            
            //3) ObjId: 1byte(UInt8)
            print("Id :")
            var data_one_obj2 : [Byte] = [0] //초기화 이후 removefirst로 없애줄것!
            for idx in 7+(iObj)*57..<7+(iObj+1)*57{  //data_one_obj = data[index_start+7+iObj*len_one_obj : index_start+7+(iObj+1)*len_one_obj]
                    data_one_obj2.append(response[idx])
            }
            data_one_obj2.removeFirst() //초기화 값 제거
            
            if let string = String(bytes: data_one_obj2, encoding: .utf8){  //Byte -> string(Decode)
                print(string.first!)
            }
            
            //4) RMat: 4byte * 9 : 36byte (Float)
            print("Rot Information") //36Byte
            for j in 0..<9{
                var data_one_obj3: [Byte] = [0]
                
                for k in 1+j*4..<1+(j+1)*4 {
                        data_one_obj3.append(response[k])
                }
                data_one_obj3.removeFirst() //4byte : 1개의 float 생성
            
                var rot: Float = 0.0
                memcpy(&rot, data_one_obj3, 4)
                print("\(rot)")
            }
            
            //5) Tvec: 4byte * 3 : 12byte (Float)
            print("Trn Information") //12Byte
            for j in 0..<3{
                var data_one_obj4: [Byte] = [0]
                
                for k in 37+j*4..<37+(j+1)*4 {
                    data_one_obj4.append(response[k])
                }
                data_one_obj4.removeFirst() //4byte : 1개의 float 생성
                
                var trn: Float = 0.0
                memcpy(&trn, data_one_obj4, 4)
                print("\(trn)")
            }
            
            
            print("X, Y Information")
            //6) Center_x: 4byte (UInt32)
            var center_x: UInt32 = 0
            var center_y: UInt32 = 0
            
            var data_one_obj5: [Byte] = [0]
            for j in 49..<53 {
                data_one_obj5.append(response[j])
            }
            data_one_obj5.removeFirst()
            let data = NSData(bytes: data_one_obj5, length: 4)
            data.getBytes(&center_x, length: 4)
            center_x = UInt32(bigEndian: center_x) //change to Big Endian
            print("\(center_x)")
            
            //7) Center_Y: 4byte (UInt32)
            var data_one_obj6: [Byte] = [0]
            for j in 53..<57 {
                data_one_obj6.append(response[j])
            }
            data_one_obj6.removeFirst()
            let data_y = NSData(bytes: data_one_obj6, length: 4)
            data_y.getBytes(&center_y, length: 4)
            center_y = UInt32(bigEndian: center_y) //change to Big Endian
            print("\(center_y)")
            
        }
        
        //print all object separately
        return String(bytes: response, encoding: .utf8)
    }
    
    private func appendToTextField(string: String) {
       print(string)
    //textView.text = textView.text.appending("\n\(string)")
    }
    
    
}


