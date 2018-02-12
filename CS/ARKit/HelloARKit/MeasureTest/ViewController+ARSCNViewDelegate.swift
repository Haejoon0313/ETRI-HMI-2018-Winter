//
//  ViewController+ARSCNViewDelegate.swift
//  HelloARKit
//
//  Created by Dev on 2018. 1. 10..
//  Copyright © 2018년 Dev. All rights reserved.
//

import ARKit

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
        //chameleon.reactToDidApplyConstraints(in: sceneView)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        //chameleon.reactToRendering(in: sceneView)
    
        guard let startingPoint = self.startingPoint else {return}
        guard let endingPoint = self.endingPoint else{return}
       
        let xDistance = abs((endingPoint.position.x) - startingPoint.position.x)
        let yDistance = abs((endingPoint.position.y) - startingPoint.position.y)
        let zDistance = abs((endingPoint.position.z) - startingPoint.position.z)
        
        DispatchQueue.main.async {
            self.xLabel.text = String(format: "%.3f", xDistance) + "m"
            self.yLabel.text = String(format: "%.3f", yDistance) + "m"
            self.zLabel.text = String(format: "%.3f", zDistance) + "m"
            self.distanceLabel.text = String(format: "%.3f", self.distanceCalcuate(x: xDistance, y: yDistance, z: zDistance)) + "m"
        }
    }
    
    // This function get called everytime to render a scene
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
       
    }
    
    //ARAnchor encodes an orientation, position and size of something in the Real World
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        //Add a new plane Detect
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
            //To detect Table only (not Floor)
            if(firstInfoBool == false){
                firstInfo = planeAnchor.transform.columns.3.y //y position of planeAnchor
                firstInfoBool = !firstInfoBool                // change true and prevent accessing.
            }
            if (planeAnchor.transform.columns.3.y >= firstInfo - 0.005 && planeAnchor.transform.columns.3.y <= firstInfo + 0.005){
                let planeNode = createPlaneDetect(planeAnchor: planeAnchor)
                node.addChildNode(planeNode)
            }
        
        DispatchQueue.main.async {
            self.label.text = "Surface Detected"
            self.hideToast()
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
            guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
            if (planeAnchor.transform.columns.3.y >= firstInfo - 0.005 && planeAnchor.transform.columns.3.y <= firstInfo + 0.005){
                node.enumerateChildNodes { (childNode, _) in
                    childNode.removeFromParentNode()
                }
                let planeNode = createPlaneDetect(planeAnchor: planeAnchor)
                node.addChildNode(planeNode)
            }
        
    }
  
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor)
    {
            guard let _ = anchor as? ARPlaneAnchor else {return}
            node.enumerateChildNodes { (childNode, _) in
                childNode.removeFromParentNode()
            }
    }
 
    
    func distanceCalcuate(x: Float, y: Float, z: Float) -> Float {
        return (sqrtf(x*x + y*y + z*z))
    }
    
    func createPlaneDetect(planeAnchor: ARPlaneAnchor ) -> SCNNode {
        
        let planeNode = SCNNode(geometry: SCNPlane(width:CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.simdPosition = float3(planeAnchor.center.x,0,planeAnchor.center.z)
        planeNode.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        planeNode.opacity = 0.15
        let staticbody = SCNPhysicsBody.static()
        planeNode.physicsBody = staticbody
        
        return planeNode
    }

}

