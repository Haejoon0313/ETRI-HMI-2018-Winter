//
//  ViewController.swift
//  MeasureTest
//
//  Created by Dev on 2018. 1. 24..
//  Copyright © 2018년 Dev. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
     let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    

    var startingPoint: SCNNode?
    var endingPoint: SCNNode?
    
    var planeAnchorinfo: ARPlaneAnchor!
   
    let host = "129.254.87.77"
    let port = 8020
    let socket = TCPSocket()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneSetting()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        socket.connect(host: host, port: port)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func sceneSetting(){
        self.sceneView.showsStatistics = true
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        self.registerRecognizer()
    }
    
    @IBAction func toggle(_ sender: UISwitch) {
        if sender.isOn == true {
            self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        }else {
            self.sceneView.debugOptions.remove([ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints])
        }
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
    
    @IBAction func capture(_ sender: Any) {
         let captureImage:UIImage = self.sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(captureImage, nil, nil, nil)
        /*
        let captureImage:UIImage = self.sceneView.snapshot()
        let imageArray: [Byte] = captureImage.pixelData()!
        
        var mms: [Byte] = [Byte]("MMS".utf8)
        let mme: [Byte] = [Byte]("MME".utf8)
        
        mms.append(contentsOf: imageArray)
        mms.append(contentsOf: mme)
        
        socket.send(mms, mms.count)
     
        let response = socket.recv(buffersize: 4096)
        
        //1) MMS: 3Byte
        let mmschecked = stringDecoder(index: 0,length: 3,received: response)
        
        if mmschecked == "MMS" {
            
            print("MMS IS Chekced!")
            
            //2) NumbOfObj: 4Byte(UInt32)
            let numOfObj = Int(intDecoder(index: 3, received: response))
            print("Numb of Objectlist = \(numOfObj)\n")
            
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
        //socket.disconnect()
         */
    }

    func registerRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        let pinchGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinch))
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        //let rotateGestureRecognizer = UIRotationGestureRecognizer(target:self, action: #selector(rotate))
        //let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        //let panGestureRecognizer = UIPanGestureRecognizer(target:self, action: #selector(pan))
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc func tap (sender: UITapGestureRecognizer) {
        
        guard let sceneView = sender.view as? ARSCNView else {return}
            let tapLocation = sender.location(in: sceneView)
            let hitTest = sceneView.hitTest( tapLocation, types: .existingPlaneUsingExtent)
        
            if !hitTest.isEmpty {
                self.addItem(hitTestResult: hitTest.first!, object: .Robot)
            }
            else{
                print("hitTest ERROR!!")
            }
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        
        guard let sceneView = sender.view as? ARSCNView else {return}
            let tapLocation = sender.location(in: sceneView)
            let hitTest = sceneView.hitTest( tapLocation, types: .existingPlaneUsingExtent)
        
            if !hitTest.isEmpty {
                self.addItem(hitTestResult: hitTest.first!, object: .Cheezit)
            }
            else{
                print("hitTest ERROR!!")
            }
    }
    
    @objc func swipe (sender: UISwipeGestureRecognizer) {
        
        guard let sceneView = sender.view as? ARSCNView else {return}
            let tapLocation = sender.location(in: sceneView)
            let hitTest = sceneView.hitTest( tapLocation, types: .existingPlaneUsingExtent)
        
            if !hitTest.isEmpty {
                self.addItem(hitTestResult: hitTest.first!, object: .Banana)
            }
            else{
                print("hitTest ERROR!!")
            }
    }
    //@objc func pan(sender: UIPanGestureRecognizer){}
    //@objc func rotate(sender: UIRotationGestureRecognizer){}
    //@objc func longPress(sender: UILongPressGestureRecognizer){}
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode() }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    
    }
    
    func addItem(hitTestResult: ARHitTestResult, object: Object){
        
        let worldPosition = hitTestResult.worldTransform.columns.3
       
        switch object {
        
            // case 1) Cheeze_it(Just simple box)
            case .Cheezit :
                let cheezeNode = SCNNode(geometry: SCNBox(width: 0.155, height: 0.225, length: 0.06, chamferRadius: 0))
                cheezeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                cheezeNode.geometry?.firstMaterial?.specular.contents = UIColor.white
                cheezeNode.opacity = 0.3
                cheezeNode.position = SCNVector3(worldPosition.x, worldPosition.y+0.1125, worldPosition.z)
                self.sceneView.scene.rootNode.addChildNode(cheezeNode)
            
                /*if self.startingPoint != nil {
                    self.startingPoint?.removeFromParentNode()
                    self.startingPoint = nil
                    return
                }*/
            
            // case 2) Banana (.scn file)
            case .Banana :
                 let bananaScene = SCNScene(named: "art.scnassets/Banana.scn")
                 guard let bananaNode = bananaScene?.rootNode.childNode(withName: "Banana", recursively: false) else{return}
                 bananaNode.position = SCNVector3 (worldPosition.x, worldPosition.y + 0.025, worldPosition.z)
                     self.sceneView.scene.rootNode.addChildNode(bananaNode)
            
                 let rotateAction = SCNAction.rotateBy(x: CGFloat(360.degreesToRadians), y: 0, z: 0, duration: 5)
                 bananaNode.runAction(rotateAction)
            
            //case 3) Dot(sphere)
            case .Dot :
                print("Dot")

                    let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.0025))
            
                    sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                    sphereNode.position = SCNVector3(worldPosition.x, worldPosition.y + 0.0025 , worldPosition.z)
                    self.sceneView.scene.rootNode.addChildNode(sphereNode)
        
                    if self.sceneView.scene.rootNode.childNodes.count % 2 == 0
                    {
                        self.startingPoint = sphereNode
                    }
                    else {
                        self.endingPoint = sphereNode
                        endingPoint?.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            
                    }
   
            // case 4) Robot Arm
            case .Robot:
                    let robotScene = SCNScene(named: "art.scnassets/Robot.scn")
                    guard let robotNode = robotScene?.rootNode.childNode(withName: "Robot", recursively: false) else{return}
                    robotNode.position = SCNVector3 (worldPosition.x, worldPosition.y + 0.08, worldPosition.z)
                    robotNode.geometry?.firstMaterial?.specular.contents = UIColor.white
                    self.sceneView.scene.rootNode.addChildNode(robotNode)
                    
                        if self.sceneView.scene.rootNode.childNodes.count % 2 == 0
                        {
                            self.startingPoint = robotNode
                        }
                        else {
                            self.endingPoint = robotNode
                            //endingPoint?.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                            let moveAction = SCNAction.move(to: (endingPoint?.position)!, duration: 3)
                            let hideAction = SCNAction.hide()
                            startingPoint?.runAction(moveAction)
                            endingPoint?.runAction(hideAction)
                        }
        }
    }
    
    func createPlaneDetect(planeAnchor: ARPlaneAnchor ) -> SCNNode {
        
        let planeNode = SCNNode(geometry: SCNPlane(width:CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.simdPosition = float3(planeAnchor.center.x,0,planeAnchor.center.z)
        planeNode.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        planeNode.opacity = 0.15
        
        return planeNode
    }

    func distanceCalcuate(x: Float, y: Float, z: Float) -> Float {
        return (sqrtf(x*x + y*y + z*z))
    }
    
}



