//
//  ViewController.swift
//  HelloARKit
//
//  Created by Dev on 2018. 1. 3..
//  Copyright © 2018년 Dev. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    @IBOutlet weak var add: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    /*
     @IBAction func add(_ sender: Any) {
     self.addText()
     }
     */
    
    
    @IBAction func reset(_ sender: Any) {
        self.restartSession()
    }
    
    /*
     func addText() {
     let textNode = SCNNode(geometry: SCNText(string: "ETRI", extrusionDepth: 0.5))
     textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
     textNode.position = SCNVector3(0, 0, -0.3)
     textNode.scale = SCNVector3(0.01, 0.007, 0.03)
     sceneView.scene.rootNode.addChildNode(textNode)
     sceneView.automaticallyUpdatesLighting = true //omni light
     }
     */
    
    func restartSession(){
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    // This function get called everytime to render a scene, need ARSCNViewDelegate (never ending roop)
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //Detecting position of CameraView
        guard let pointOfView = sceneView.pointOfView else {return} // the node from which the scene's contents viewed for rendering
        
        let transform = pointOfView.transform
        
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33) //column:3
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)//column:4
        let curreontCameraView = orientation + location
        
        DispatchQueue.main.async {
            if self.add.isHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
                sphereNode.position = curreontCameraView
                
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
                
                
                
                //sphereNode.opacity = 0.5
                //pyramidNode.eulerAngles = SCNVector3( Float(90.degreesToRadians),0,0)
                /*
                 let pyramidNode = SCNNode(geometry: SCNPyramid(width: 0.04, height: 0.06, length: 0.02))
                 pyramidNode.transform = transform
                 pyramidNode.opacity = 0.5
                 //pyramidNode.eulerAngles = SCNVector3( Float(90.degreesToRadians),0,0)
                 self.sceneView.scene.rootNode.addChildNode(pyramidNode)
                 pyramidNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
                 */
            }
        }
        
    }
    
}

extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
    
}


func +(left:SCNVector3 , right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

