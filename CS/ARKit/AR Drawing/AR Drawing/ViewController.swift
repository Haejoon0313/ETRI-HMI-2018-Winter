//
//  ViewController.swift
//  AR Drawing
//
//  Created by 이충신 on 2018. 1. 7..
//  Copyright © 2018년 GGOMMI. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var draw: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true // information about frames per second and scene rendering performances.
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This function get called everytime to render a scene, ARSCNViewDelegate (never ending roop)
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        print("rendering")
        
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location
        
       //print(orientation.x , orientation.y, orientation.z)
        
        
        if draw.isHighlighted{
            let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
            sphereNode.position = currentPositionOfCamera
            sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            self.sceneView.scene.rootNode.addChildNode(sphereNode)
            
            print("draw button is being pressed")
        }
        
    }

}

func +(left:SCNVector3 , right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

