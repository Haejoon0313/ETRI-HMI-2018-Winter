//
//  ViewController.swift
//  HelloARKit
//
//  Created by Dev on 2018. 1. 3..
//  Copyright © 2018년 Dev. All rights reserved.
//


import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    var cameraTransform:SCNNode!
    var planeAnchorinfo: ARPlaneAnchor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultSetting()
        //Information about camerTransform
        guard let pointOfView = sceneView.pointOfView else {return}
        self.cameraTransform = pointOfView
        
    }
    
    func defaultSetting(){
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        self.configuration.planeDetection = .horizontal //to detect horizontal surfaces
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
    }

    @IBAction func reset(_ sender: Any) {
        self.restartSession()
    }
    
    
    //restart the session : reset tracking and existingAnchors
    func restartSession(){
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }

    //Add pyramid
    @IBAction func add(_ sender: Any) {
        
        let pyramidNode = SCNNode(geometry: SCNPyramid(width: 0.04, height: 0.06, length: 0.02))
        pyramidNode.transform = self.cameraTransform.transform
        pyramidNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        pyramidNode.opacity = 0.75
        self.sceneView.scene.rootNode.addChildNode(pyramidNode)
        
    }
    
    func createPlane(planeAnchor: ARPlaneAnchor ) -> SCNNode {
        
       let planeNode = SCNNode(geometry: SCNPlane(width:CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.simdPosition = float3(planeAnchor.center.x,0,planeAnchor.center.z)
        planeNode.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        planeNode.opacity = 0.25
        
        return planeNode
    }
   
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}


func +(left:SCNVector3 , right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

