//
//  ViewController.swift
//  HelloARKit
//
//  Created by Dev on 2018. 1. 3..
//  Copyright © 2018년 Dev. All rights reserved.
//
//TODO:
//1) plane Detection 생성 (checked)
//2) device의 orientation 따라하기

import UIKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var cameraTransform:SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        self.configuration.planeDetection = .horizontal //to detect horizontal surfaces
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        
        guard let pointOfView = sceneView.pointOfView else {return}
        self.cameraTransform = pointOfView
    }
    
    @IBAction func reset(_ sender: Any) {
        self.restartSession()
    }
    
    
   
    @IBAction func add(_ sender: Any) {
        let pyramidNode = SCNNode(geometry: SCNPyramid(width: 0.04, height: 0.06, length: 0.02))
        pyramidNode.transform = self.cameraTransform.transform
        pyramidNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        pyramidNode.opacity = 0.75
        let action = SCNAction.rotateBy(x:0, y:CGFloat(360.degreesToRadians),z:0, duration: 8)
        pyramidNode.runAction(action)
        self.sceneView.scene.rootNode.addChildNode(pyramidNode)
    }
    
    //restart the session : reset tracking and existingAnchors
    func restartSession(){
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    
    func createPlane(planeAnchor: ARPlaneAnchor ) -> SCNNode {
        
        //let planeNode = SCNNode(geometry:SCNBox(width: CGFloat(planeAnchor.extent.x), height: 0.1 , length: CGFloat(planeAnchor.extent.z), chamferRadius: 0))
        //planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        //planeNode.simdPosition = float3(planeAnchor.center.x,0,planeAnchor.center.z)
        //planeNode.opacity = 0.25
        
        let planeNode = SCNNode(geometry: SCNPlane(width:CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.simdPosition = float3(planeAnchor.center.x,0,planeAnchor.center.z)
        planeNode.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        planeNode.opacity = 0.25
        return planeNode
    }
    
    // This function get called everytime to render a scene, need ARSCNViewDelegate (never ending roop)
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        /*
         DispatchQueue.main.async {
         if self.add.isHighlighted {
         
         }
         
         }
         */
        
    }
    
    //ARAnchor encodes an orientation position and size of something in the Real World
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // print("New surface")
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNode = createPlane(planeAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // print("updating floor's anchor")
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let planeNode = createPlane(planeAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        //print("remove previous surface")
        guard let _ = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
    
}


extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}


func +(left:SCNVector3 , right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

