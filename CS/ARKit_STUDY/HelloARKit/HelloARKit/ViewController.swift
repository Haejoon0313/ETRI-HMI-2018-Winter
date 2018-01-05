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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.session.run(configuration)
        addText()
    }
    
    func addText() {
    
        let text = SCNText(string: "ETRI HRI", extrusionDepth: 0.5)
        /*
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        text.materials = [material]
        */
        let node = SCNNode()
        node.geometry = text
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        node.position = SCNVector3(0, 0, -0.5)
        node.scale = SCNVector3(0.01, 0.007, 0.03)
        sceneView.scene.rootNode.addChildNode(node)
        //sceneView.automaticallyUpdatesLighting = true
        
    }


}

