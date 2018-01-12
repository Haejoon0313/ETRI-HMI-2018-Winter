//
//  ViewController.swift
//  ClientTest
//
//  Created by Dev on 2018. 1. 12..
//  Copyright © 2018년 Dev. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    let host = "127.0.0.1"
    let port = 9000
    var client: TCPClient?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = TCPClient(address: host, port: Int32(port))
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.sceneView.showsStatistics = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendButtonAction(_ sender: Any) {
       // print("send Image :) ")
        var captureImage:UIImage = self.sceneView.snapshot()
        dump(captureImage)
        
        guard let client = client else { return }
        
        switch client.connect(timeout: 10) {
        case .success:
            appendToTextField(string: "Connected to host \(client.address)")
            if let response = sendRequest(string: "GET / HTTP/1.0\n\n", using: client) {
                appendToTextField(string: "Response: \(response)")
            }
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
        
    }
    
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        appendToTextField(string: "Sending data ... ")
        
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            appendToTextField(string: String(describing: error))
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
    
    private func appendToTextField(string: String) {
        print(string)
        //textView.text = textView.text.appending("\n\(string)")
    }

    
}



