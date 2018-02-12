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
  
    var firstInfo: Float!
    var firstInfoBool: Bool = false
    
   // let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    
    //Slide Menu property
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    var isSlideMenuHidden = true
    
    //Toast
    @IBOutlet weak var toast: UIVisualEffectView!
    @IBOutlet weak var label: UILabel!
    
    //Text Label (Show Distance)
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    //Measurment property
    var startingPoint: SCNNode?
    var endingPoint: SCNNode?
    var measureDot: [SCNNode] = [SCNNode]()
    @IBOutlet weak var measureAim: UIButton!    // View의 Center에 있는 Aim 표시
    @IBOutlet weak var rulerButton: UIButton!   // Measure를 위해 Dot 생성 버튼
    
    var toggleSelected: Bool = true
    var crossMade: Bool = false               //Cross Marker 생성여부
    var crossMarker: SCNNode!
    
    var objectSelect: Object = .Nothing
    var cameraMatrix: simd_float4x4!
    let menuRootNode = SCNNode()
    
    //Animation property (Chameleon)
    //var chameleon = Chameleon()
    //let unhide = SCNAction.unhide()
    //let hide = SCNAction.hide()

    //Socket property
    let host = "129.254.87.77"
    let port = 8020
    let socket = TCPSocket()
    var imageNumb = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetTracking()
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        registerRecognizer()
        addLight()
        sideMenuConstraint.constant = -140

        socket.connect(host: host, port: port)  //If you want connect to Server, enable this line.
        //sceneView.scene = chameleon
        //sceneView.automaticallyUpdatesLighting = false
        //chameleon.hide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard ARWorldTrackingConfiguration.isSupported else {fatalError("ARKit is not available on this device.")}
        UIApplication.shared.isIdleTimerDisabled = true  // Prevent the screen from being dimmed after a while.
    }

    
    @IBAction func toggle(_ sender: UISwitch) {
        if sender.isOn == true {
            self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
            toggleSelected = true
        }else {
            self.sceneView.debugOptions.remove([ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints])
            toggleSelected = false
        }
    }
    
    @IBAction func organizeBtnPressed(_ sender: Any) {
        if isSlideMenuHidden { showSlideMenu() }
        else{ hideSlideMenu() }
        isSlideMenuHidden = !isSlideMenuHidden
    }
    
    @IBAction func reset(_ sender: Any) {
        resetTracking()
        crossMade = false
    }
    
    func resetTracking() {
         self.sceneView.session.pause()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in node.removeFromParentNode() }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        hideMeasureElement(true)  //To hide Distance_Label, Measure_Aim, Ruler_Button (When Measure Menu is selected.)
    }

    func registerRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        let rotateGestureRecognizer = UIRotationGestureRecognizer(target:self, action: #selector(rotate))
        let panGestureRecognizer = UIPanGestureRecognizer(target:self, action: #selector(pan))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(rotateGestureRecognizer)
        self.sceneView.addGestureRecognizer(panGestureRecognizer)
        //let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress)) //longGestureRecognizer.minimumPressDuration = 0.5
        //@objc func longPress(sender: UILongPressGestureRecognizer){ if sender.state == .began }
        //let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        //let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let tapLocation = sender.location(in: sceneView)
        
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)  //For just Touch on the Detected plane
        let hitTest2 = sceneView.hitTest(tapLocation)   // For ARMenu Touching
        
            if !hitTest.isEmpty {
                self.addItem(hitTestResult: hitTest.first!, object: objectSelect)
            }
            if !hitTest2.isEmpty {
                let result = hitTest2.first!
                    if let targetName = result.node.name{
                        switch targetName {
                            case "banana", "Banana":
                                    objectSelect = .Banana
                            case "cheezeit", "Cheezeit":
                                objectSelect = .Cheezit
                            case "robot", "Robot":
                                    objectSelect = .Robot
                            case "mustard", "Mustard":
                                    objectSelect = .Mustard
                            case "drill", "Drill":
                                    objectSelect = .Drill
                            case "soup", "Soup":
                                    objectSelect = .Soup
                            default:
                                    objectSelect = .Nothing
                            }
                            menuRootNode.removeFromParentNode()
                            menuRootNode.enumerateChildNodes { (childNode, _) in
                                childNode.removeFromParentNode()
                            }
                    }   else {return}
            }
    }

    @IBAction func measureButton(_ sender: UIButton) {
        hideSlideMenu()
        hideMeasureElement(false)
        objectSelect = .CrossMarker
        rulerButton.isEnabled = false
    }
    @IBAction func objectlistButton(_ sender: UIButton) {
        hideSlideMenu()
        hideMeasureElement(true)
        
        let rotateAction = SCNAction.rotateBy(x: 0, y: 360 , z: 0, duration: 180)
        let boxPostionGap = 0.0225 - 0.008
       
        guard let currentFrame = sceneView.session.currentFrame else {return}       //ObjeclistButton을 누를 당시의 Frame 정보
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.1                                        // To show Menu 10cm away.(Z axis)
        cameraMatrix = simd_mul(transform, translationMatrix)

            menuRootNode.simdTransform = cameraMatrix
            let menuScale: SCNVector3 = SCNVector3(0.001,0.001,0.001)               //(0.001,0.0003,0.01)
            
            let menuBoard = SCNNode(geometry: SCNPlane(width: 0.06 , height: 0.12))
            menuBoard.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
            menuBoard.geometry?.firstMaterial?.isDoubleSided = true
            menuBoard.position = SCNVector3(0,0,-0.002)
            menuRootNode.addChildNode(menuBoard)
        
            /*
            let titleMenu = SCNNode(geometry: SCNText(string: "Object List", extrusionDepth: 0.1))
            titleMenu.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            titleMenu.position = SCNVector3(-0.03,0.045,0)
            titleMenu.scale = menuScale
            */
            let titleMenu = createImageMenu()
            menuRootNode.addChildNode(titleMenu)
            
            let bananaMenu = SCNNode(geometry: SCNText(string: "1.Banana", extrusionDepth: 0.1))
            bananaMenu.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
            bananaMenu.position = SCNVector3(-0.03,0.03,0)
            bananaMenu.name = "banana"
            bananaMenu.scale = menuScale
            let bananaBox = SCNNode(geometry: SCNBox(width: 0.06, height: 0.01, length: 0.001, chamferRadius: 0))
            bananaBox.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            bananaBox.position = SCNVector3(0,0.037,-0.001)
            bananaBox.name = "banana"
            menuRootNode.addChildNode(bananaBox)
            menuRootNode.addChildNode(bananaMenu)
            guard let bananaNode = SCNScene(named: "art.scnassets/Banana.scn")?.rootNode.childNode(withName: "Banana", recursively: false)else {return}
            bananaNode.scale = SCNVector3(0.08,0.08,0.08)
            bananaNode.position = SCNVector3(0.04,0,0)
            bananaNode.eulerAngles = SCNVector3 (0 , 0, 90.degreesToRadians)
            let rotateAction2 = SCNAction.rotateBy(x: 360, y: 0 , z: 0, duration: 180)
            bananaNode.runAction(SCNAction.repeatForever(rotateAction2))
            bananaBox.addChildNode(bananaNode)
            
            let cheezeMenu = SCNNode(geometry: SCNText(string: "2.CheezeIt", extrusionDepth: 0.1))
            cheezeMenu.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            cheezeMenu.position = SCNVector3(-0.03,0.015,0)
            cheezeMenu.name = "cheezeit"
            cheezeMenu.scale = menuScale
            let cheezeBox = SCNNode(geometry: SCNBox(width: 0.06, height: 0.01, length: 0.001, chamferRadius: 0))
            cheezeBox.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            cheezeBox.position = SCNVector3(0,0.037 - boxPostionGap ,-0.001)
            cheezeBox.name = "cheezeit"
            menuRootNode.addChildNode(cheezeBox)
            menuRootNode.addChildNode(cheezeMenu)
            guard let cheezeNode = SCNScene(named: "art.scnassets/Cheezeit.scn")?.rootNode.childNode(withName: "Cheezeit", recursively: false)else {return}
            cheezeNode.scale = SCNVector3(0.07,0.07,0.07)
            cheezeNode.position = SCNVector3(0.04,0,0)
            cheezeNode.runAction(SCNAction.repeatForever(rotateAction))
            cheezeBox.addChildNode(cheezeNode)
    
            let robotMenu = SCNNode(geometry: SCNText(string: "3.Robot", extrusionDepth: 0.1))
            robotMenu.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
            robotMenu.position = SCNVector3(-0.03,0,0)
            robotMenu.scale = menuScale
            robotMenu.name = "robot"
            let robotBox = SCNNode(geometry: SCNBox(width: 0.06, height: 0.01, length: 0.001, chamferRadius: 0))
            robotBox.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            robotBox.position = SCNVector3(0,0.037 - 2*boxPostionGap,-0.001)
            robotBox.name = "robot"
            menuRootNode.addChildNode(robotBox)
            menuRootNode.addChildNode(robotMenu)
            guard let robotNode = SCNScene(named: "art.scnassets/Robot.scn")?.rootNode.childNode(withName: "Robot", recursively: false)else {return}
            robotNode.scale = SCNVector3(0.003,0.003,0.0003)
            robotNode.position = SCNVector3(0.04,-0.005,0)
            robotNode.runAction(SCNAction.repeatForever(rotateAction))
            robotBox.addChildNode(robotNode)
        
            let mustardMenu = SCNNode(geometry: SCNText(string: "4.Mustard", extrusionDepth: 0.1))
            mustardMenu.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
            mustardMenu.position = SCNVector3(-0.03,-0.015,0)
            mustardMenu.scale = menuScale
            mustardMenu.name = "mustard"
            let mustardBox = SCNNode(geometry: SCNBox(width: 0.06, height: 0.01, length: 0.001, chamferRadius: 0))
            mustardBox.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            mustardBox.position = SCNVector3(0,0.037 - 3*boxPostionGap,-0.001)
            mustardBox.name = "mustard"
            menuRootNode.addChildNode(mustardBox)
            menuRootNode.addChildNode(mustardMenu)
            guard let mustardNode = SCNScene(named: "art.scnassets/Mustard.scn")?.rootNode.childNode(withName: "Mustard", recursively: false)else {return}
            mustardNode.position = SCNVector3(0.04, 0, 0)
            mustardNode.scale = SCNVector3(0.08,0.08,0.08)
            mustardNode.runAction(SCNAction.repeatForever(rotateAction))
            mustardBox.addChildNode(mustardNode)
        
            let drillMenu = SCNNode(geometry: SCNText(string: "5.Drill", extrusionDepth: 0.1))
            drillMenu.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
            drillMenu.position = SCNVector3(-0.03,-0.03,0)
            drillMenu.scale = menuScale
            drillMenu.name = "drill"
            let drillBox = SCNNode(geometry: SCNBox(width: 0.06, height: 0.01, length: 0.001, chamferRadius: 0))
            drillBox.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            drillBox.position = SCNVector3(0,0.037 - 4*boxPostionGap,-0.001)
            drillBox.name = "drill"
            menuRootNode.addChildNode(drillBox)
            menuRootNode.addChildNode(drillMenu)
            guard let drillNode = SCNScene(named: "art.scnassets/Drill.scn")?.rootNode.childNode(withName: "Drill", recursively: false)else {return}
            drillNode.position = SCNVector3(0.04, 0, 0)
            drillNode.scale = SCNVector3(0.06,0.06,0.06)
            drillNode.runAction(SCNAction.repeatForever(rotateAction))
            drillBox.addChildNode(drillNode)
        
            let soupMenu = SCNNode(geometry: SCNText(string: "6.Soup", extrusionDepth: 0.1))
            soupMenu.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            soupMenu.position = SCNVector3(-0.03,-0.045,0)
            soupMenu.scale = menuScale
            soupMenu.name = "soup"
            let soupBox = SCNNode(geometry: SCNBox(width: 0.06, height: 0.01, length: 0.001, chamferRadius: 0))
            soupBox.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            soupBox.position = SCNVector3(0,0.037 - 5*boxPostionGap,-0.001)
            soupBox.name = "soup"
            menuRootNode.addChildNode(soupBox)
            menuRootNode.addChildNode(soupMenu)
            guard let soupNode = SCNScene(named: "art.scnassets/Soup.scn")?.rootNode.childNode(withName: "Soup", recursively: false)else {return}
            soupNode.position = SCNVector3(0.04, 0, 0)
            soupNode.scale = SCNVector3(0.09,0.09,0.09)
            soupNode.runAction(SCNAction.repeatForever(rotateAction))
            soupBox.addChildNode(soupNode)
     
            self.sceneView.scene.rootNode.addChildNode(menuRootNode)
    }
    
    @objc func rotate (_ gesture: UIRotationGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        let arHitTestResult = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        if !arHitTestResult.isEmpty {
            guard gesture.state == .changed else { return }
            crossMarker.eulerAngles.y -= Float(gesture.rotation)
            gesture.rotation = 0
        }
    }
    
    @objc func pan(sender: UIPanGestureRecognizer){
        let location = sender.location(in: sceneView)
        let arHitTestResult = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        if !arHitTestResult.isEmpty {
            let hit = arHitTestResult.first!
            let position = hit.worldTransform.columns.3
            if sender.state == .began || sender.state == .changed {
                if(crossMarker != nil){
                    crossMarker.position = SCNVector3(position.x - 0.02 ,position.y + 0.005 ,position.z - 0.02)
                }
            }
        }
    }
    //@objc func rotate(sender: UIRotationGestureRecognizer){}
    //@objc func pinch(sender: UIPinchGestureRecognizer) {}
    //@objc func swipe (sender: UISwipeGestureRecognizer) {}
    //override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {} //This is shake motion.
    
    @IBAction func rulerButton(_ sender: Any) {
        if let worldPos = sceneView.realWorldVector(screenPos: view.center){
            let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.0025))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                sphereNode.position = SCNVector3(worldPos.x, worldPos.y + 0.0025 ,worldPos.z)
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                measureDot.append(sphereNode)
        }
            if measureDot.count == 2 {
                self.startingPoint = measureDot[0]
                self.endingPoint = measureDot[1]
                measureDot.removeAll()
            }
    }
    
    func addItem(hitTestResult: ARHitTestResult, object: Object){
        
        let worldPosition = hitTestResult.worldTransform.columns.3 //position
 
        switch object {
        
            case .Banana :
                let bananaScene = SCNScene(named: "art.scnassets/Banana.scn")
                guard let bananaNode = bananaScene?.rootNode.childNode(withName: "Banana", recursively: false) else{return}
                bananaNode.position = SCNVector3 (worldPosition.x, worldPosition.y + 0.0185 , worldPosition.z)
                self.sceneView.scene.rootNode.addChildNode(bananaNode)
                //  let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bananaNode, options: [SCNPhysicsShape.Option.keepAsCompound: true]))
                //  bananaNode.physicsBody = body
                break
            
            case .Cheezit :
                let cheezeScene = SCNScene(named: "art.scnassets/Cheezeit.scn")
                guard let cheezeNode = cheezeScene?.rootNode.childNode(withName: "Cheezeit", recursively: false)else {return}
                cheezeNode.position = SCNVector3(worldPosition.x, worldPosition.y + 0.1125, worldPosition.z)
                self.sceneView.scene.rootNode.addChildNode(cheezeNode)
                break
            
            case .Robot:
                let robotScene = SCNScene(named: "art.scnassets/Robot.scn")
                guard let robotNode = robotScene?.rootNode.childNode(withName: "Robot", recursively: false) else{return}
                robotNode.position = SCNVector3 (worldPosition.x, worldPosition.y + 0.04 , worldPosition.z)
                self.sceneView.scene.rootNode.addChildNode(robotNode)
                break
            
            case .Mustard:
                let mustardScene = SCNScene(named: "art.scnassets/Mustard.scn")
                guard let mustardNode = mustardScene?.rootNode.childNode(withName: "Mustard", recursively: false)else {return}
                mustardNode.position = SCNVector3(worldPosition.x, worldPosition.y + 0.0955, worldPosition.z)
                self.sceneView.scene.rootNode.addChildNode(mustardNode)
                break
            
            case .Drill:
                let drillScene = SCNScene(named: "art.scnassets/Drill.scn")
                guard let drillNode = drillScene?.rootNode.childNode(withName: "Drill", recursively: false)else {return}
                drillNode.position = SCNVector3(worldPosition.x, worldPosition.y + 0.0935, worldPosition.z)
                self.sceneView.scene.rootNode.addChildNode(drillNode)
                break
            
            case .Soup:
                let soupScene = SCNScene(named: "art.scnassets/Soup.scn")
                guard let soupNode = soupScene?.rootNode.childNode(withName: "Soup", recursively: false)else {return}
                soupNode.position = SCNVector3(worldPosition.x, worldPosition.y + 0.051, worldPosition.z)
                self.sceneView.scene.rootNode.addChildNode(soupNode)
                break
            
            case .CrossMarker:
                //if let worldPos = sceneView.realWorldVector(screenPos: view.center){}
                    if crossMade == false {
                        crossMarker = createCross(worldPos: SCNVector3(worldPosition.x, worldPosition.y, worldPosition.z))
                        self.sceneView.scene.rootNode.addChildNode(crossMarker)
                        crossMade = !crossMade                              //change true and enable rullerButton to make Dot(Start, End Position)
                        rulerButton.isEnabled = true
                    }
                
            default:
                print("Ther's no item")
                //chameleon.setTransform(hitTestResult.worldTransform)
                //chameleon.show()
                //chameleon.reactToInitialPlacement(in: sceneView)
        }
        
    }
    func createCross(worldPos: SCNVector3) -> SCNNode {
        let crossNode = SCNNode(geometry: SCNPlane(width: 0.06, height: 0.065))
        crossNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Cross")
        crossNode.geometry?.firstMaterial?.isDoubleSided = true
        crossNode.simdPosition = float3(worldPos.x,worldPos.y + 0.005,worldPos.z)
        crossNode.eulerAngles = SCNVector3(-90.degreesToRadians,0,0)
        crossNode.opacity = 0.2
        return crossNode
    }
    
    func createImageMenu() -> SCNNode {
        let menuNode = SCNNode(geometry: SCNPlane(width: 0.06, height: 0.01))
        menuNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "ObjectList")
        menuNode.geometry?.firstMaterial?.isDoubleSided = true
        menuNode.position = SCNVector3(0,0.06,0)
        return menuNode
    }
    
    func savePosition() -> [Float] {
        let startPosition = startingPoint?.position
        let endPosition = endingPoint?.position
        
        var positionArray = [Float](repeating: 0.0 , count: 6)
        positionArray.append((startPosition?.x)!)
        positionArray.append((startPosition?.y)!)
        positionArray.append((startPosition?.z)!)
        positionArray.append((endPosition?.x)!)
        positionArray.append((endPosition?.y)!)
        positionArray.append((endPosition?.z)!)
        
        return positionArray
    }
    
    //Light Element
    
    func addLight(){
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
  
}

func +(left:SCNVector3 , right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}





