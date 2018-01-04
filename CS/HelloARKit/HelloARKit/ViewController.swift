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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addText()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
    }
    
    func addText() {
    
        let text = SCNText(string: "Hello ModMan", extrusionDepth: 0.5)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        text.materials = [material]
        
        let node = SCNNode()
        node.position = SCNVector3(0, 0, 0)
        node.scale = SCNVector3(0.01, 0.01, 0.01)
        node.geometry = text
        
        sceneView.scene.rootNode.addChildNode(node)
        //sceneView.automaticallyUpdatesLighting = true
        
    }


}

