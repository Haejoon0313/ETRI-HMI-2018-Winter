//
//  ViewController+ARSCNViewDelegate.swift
//  HelloARKit
//
//  Created by Dev on 2018. 1. 10..
//  Copyright © 2018년 Dev. All rights reserved.
//

import ARKit

extension ViewController: ARSCNViewDelegate {
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let startingPoint = self.startingPoint else {return}
        guard let endingPoint = self.endingPoint else{return}
        //guard let pointOfView = self.sceneView.pointOfView else {return}
        
        //let transform = pointOfView.transform
        //location = SCNVector3(transform.m41, transform.m42, transform.m43) //pointOfView의 location
        //let xDistance = location.x - startingPoint.position.x
        //let yDistance = location.y - startingPoint.position.y
        //let zDistance = location.z - startingPoint.position.z
        
        //Banana Version
        let xDistance = abs((endingPoint.position.x) - startingPoint.position.x)
        let yDistance = abs((endingPoint.position.y) - startingPoint.position.y)
        let zDistance = abs((endingPoint.position.z) - startingPoint.position.z)
        
        
        DispatchQueue.main.async {
            self.xLabel.text = String(format: "%.2f", xDistance) + "m"
            self.yLabel.text = String(format: "%.2f", yDistance) + "m"
            self.zLabel.text = String(format: "%.2f", zDistance) + "m"
            self.distanceLabel.text = String(format: "%.2f", self.distanceCalcuate(x: xDistance, y: yDistance, z: zDistance)) + "m"
        }
    }
    
    // This function get called everytime to render a scene
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //DispatchQueue.main.async {
        //    if self.add.isHighlighted {
        //    }
        //}
    }
    
    //ARAnchor encodes an orientation, position and size of something in the Real World
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {   // print("New surface")
            guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
            let planeNode = createPlaneDetect(planeAnchor: planeAnchor)
            node.addChildNode(planeNode)
 
        let light = SCNLight()
        light.type = .directional
        light.color = UIColor(white: 1.0, alpha: 1.0)
        light.shadowColor = UIColor(white: 0.0, alpha: 0.8).cgColor
        let lightNode = SCNNode()
        lightNode.eulerAngles = SCNVector3Make(-.pi / 3, .pi / 4, 0)
        lightNode.light = light
        sceneView.scene.rootNode.addChildNode(lightNode)
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.8, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        sceneView.scene.rootNode.addChildNode(ambientNode)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {   // print("updating floor's anchor")
            guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
            node.enumerateChildNodes { (childNode, _) in
                childNode.removeFromParentNode()
            }
            let planeNode = createPlaneDetect(planeAnchor: planeAnchor)
            node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor)
    {   //print("remove previous surface")
            guard let _ = anchor as? ARPlaneAnchor else {return}
            node.enumerateChildNodes { (childNode, _) in
                childNode.removeFromParentNode()
            }
    }

}

