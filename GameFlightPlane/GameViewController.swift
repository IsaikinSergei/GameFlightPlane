//
//  GameViewController.swift
//  GameFlightPlane
//
//  Created by Sergei Isaikin on 16.12.2020.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    // MARK: - Outlets
    let scoreLabel = UILabel()
    let restartButton = UIButton()
    
    // MARK: - Properties
    var duration: TimeInterval = 5
    var hit = true
    var scene: SCNScene!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
   

    // MARK: - Methods
    
    func addShip() {
        // Get the ship
        let ship = getShip()
        
        
        // Set ship coordinate
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -25 ... 25)
        let z = -150
    
        ship.position = SCNVector3(x, y, z)
        ship.look(at: SCNVector3(2 * x, 2 * y, 2 * z))
        
        // Add flight animation
        ship.runAction(.move(to: SCNVector3(), duration: duration)) {
            self.removeShip()
            self.newGame()
        }
        
        // Note that the plane is not hit
        hit = false
        
        // Add the ship to the scene
        scene.rootNode.addChildNode(ship)
        
    }
    
    func configureLayout() {
        let scnView = view as! SCNView
        
        // Add button
        let width: CGFloat = 200
        let height: CGFloat = 100
        let x = scnView.frame.midX - width / 2
        let y = scnView.frame.midY - height / 2
        
        restartButton.backgroundColor = .red
        restartButton.frame = CGRect(x: x, y: y, width: width, height: height)
        restartButton.isHidden = true
        restartButton.layer.cornerRadius = 15
        restartButton.setTitle("New Game", for: .normal)
        restartButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        restartButton.titleLabel?.textColor = .yellow
        
        scnView.addSubview(restartButton)
        
        // Add label
        scoreLabel.font = UIFont.systemFont(ofSize: 30)
        scoreLabel.frame = CGRect(x: 0, y: 0, width: scnView.frame.width, height: 100)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .white
        
        scnView.addSubview(scoreLabel)
        
        score = 0
        
        // Add action for restart button tapped
        restartButton.addTarget(self, action: #selector(restartButtonTapped), for: .touchUpInside)
        
        
    }
    
    func getShip() -> SCNNode {
        // Get the scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Get the ship
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // Return the ship
        return ship
        
    }
    
    func newGame() {
        guard hit else {
            DispatchQueue.main.async {
                self.restartButton.isHidden = false
            }
            
            return
            
        }
        
        
        // add ship to the scene
        addShip()
        
        // increase difficulty
        duration *= 0.9
    }
    
    func removeShip() {
        scene.rootNode.childNode(withName: "ship", recursively: true)?.removeFromParentNode()
    }
    
    
    
    // MARK: - Inherited Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
//        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
//
//        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
//
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // remove existing ship
        removeShip()
        
        // start new game
        newGame()
        
        // configure UI elements
        configureLayout()
        
    }
    
    
    
    // MARK: - Actions
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // note that the plane is not hit
            hit = true
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.removeShip()
                self.newGame()
                self.score += 1
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    @objc
    func restartButtonTapped() {
        duration = 5
        hit = true
        restartButton.isHidden = true
        score = 0
        
        newGame()
    }
    
    // MARK: - Computed Properties
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
