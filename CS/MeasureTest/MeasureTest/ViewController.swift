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
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var startingPoint: SCNNode?
    var endingPoint: SCNNode?
    //var cameraTransform:SCNNode!
    
    var planeAnchorinfo: ARPlaneAnchor!
    let configuration = ARWorldTrackingConfiguration()
    
    var fixedYchecked: Bool = false
    var fixedY: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneSetting()
       //guard let pointOfView = sceneView.pointOfView else {return}
       //self.cameraTransform = pointOfView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func sceneSetting(){
        
        self.sceneView.showsStatistics = true
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(measureTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func resetButton(_ sender: Any) {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode() }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    
    
    @objc func measureTap (sender: UITapGestureRecognizer) {
        
        guard let sceneView = sender.view as? ARSCNView else {return}
            
            let tapLocation = sender.location(in: sceneView)
            let hitTest = sceneView.hitTest( tapLocation, types: .existingPlaneUsingExtent)
        
            if !hitTest.isEmpty {
                self.addItem(hitTestResult: hitTest.first!)
            }
            else{
                print("hitTest ERROR!!")
            }
      
    }
    
    func addItem(hitTestResult: ARHitTestResult){
        
        let thirdColumn = hitTestResult.worldTransform.columns.3 // 4번째 행은 hitTest Result에 대한 World좌표계의 position을 의미한다.
        //guard let currentFrame = sceneView.session.currentFrame else{return}
        
        if fixedYchecked == false {
            fixedY = thirdColumn.y
            fixedYchecked = true
        }
        
//    //case 1) Cheeze_it(Just simple box)
//        let boxNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.15, length: 0.05, chamferRadius: 0))
//        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//        boxNode.opacity = 0.75
//        boxNode.position = SCNVector3(thirdColumn.x, thirdColumn.y+0.0751, thirdColumn.z)
//        self.sceneView.scene.rootNode.addChildNode(boxNode)
//
//        /*if self.startingPoint != nil {
//            self.startingPoint?.removeFromParentNode()
//            self.startingPoint = nil
//            return
//        }*/
       
//    //case 2) Banana (.scn file)
//                let bananaScene = SCNScene(named: "art.scnassets/Banana.scn")
//                guard let bananaNode = bananaScene?.rootNode.childNode(withName: "Banana", recursively: false) else{return}
//                bananaNode.position = SCNVector3 (thirdColumn.x, fixedY + 0.025, thirdColumn.z)
//                self.sceneView.scene.rootNode.addChildNode(bananaNode)
//
//                if self.sceneView.scene.rootNode.childNodes.count % 2 == 1{
//                    self.startingPoint = bananaNode
//                }
//                else {  self.endingPoint = bananaNode   }

        
    //case 3) Dot(sphere)
        
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.0025))
        
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        sphereNode.position = SCNVector3(thirdColumn.x, thirdColumn.y + 0.0025 , thirdColumn.z)
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
        
        let xValue = String(format: "%.2f", sphereNode.position.x)
        let yValue = String(format: "%.2f", sphereNode.position.y)
        let zValue = String(format: "%.2f", sphereNode.position.z)
        let valueText = "( " + xValue + "," + yValue + "," + zValue + ")"
        
        let textNode = SCNNode(geometry: SCNText(string: valueText, extrusionDepth: 0.01))
        textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        textNode.scale = SCNVector3 (0.005, 0.003,0.002)
        textNode.position = SCNVector3(thirdColumn.x - 0.0025,thirdColumn.y,thirdColumn.z - 0.001)
        sphereNode.addChildNode(textNode)
        
        
        if self.sceneView.scene.rootNode.childNodes.count % 2 == 0
        {
            self.startingPoint = sphereNode
        }
        else {
            self.endingPoint = sphereNode
            //endingPoint?.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            let action = SCNAction.move(to: (endingPoint?.position)!, duration: 3)
            let hide = SCNAction.hide()
            endingPoint?.runAction(hide)
            startingPoint?.runAction(action)
        }
        
    //case 4) Robot Arm
        //                let robotScene = SCNScene(named: "art.scnassets/Robot.scn")
        //                guard let robotNode = robotScene?.rootNode.childNode(withName: "Robot", recursively: false) else{return}
        //                robotNode.position = SCNVector3 (thirdColumn.x, fixedY + 0.025, thirdColumn.z)
        //                self.sceneView.scene.rootNode.addChildNode(robotNode)
        //
        //                if self.sceneView.scene.rootNode.childNodes.count % 2 == 1{
        //                    self.startingPoint = robotNode
        //                }
        //                else {  self.endingPoint = robotNode   }
        
        
        
    }
    
    func createPlaneDetect(planeAnchor: ARPlaneAnchor ) -> SCNNode {
        
        let planeNode = SCNNode(geometry: SCNPlane(width:CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.simdPosition = float3(planeAnchor.center.x,0,planeAnchor.center.z)
        planeNode.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        planeNode.opacity = 0.25
        
        return planeNode
    }

    func distanceCalcuate(x: Float, y: Float, z: Float) -> Float {
        return (sqrtf(x*x + y*y + z*z))
    }
    
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}

