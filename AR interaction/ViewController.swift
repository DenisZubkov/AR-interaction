//
//  ViewController.swift
//  AR interaction
//
//  Created by Denis Zubkov on 17/09/2018.
//  Copyright © 2018 Denis Zubkov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
        if let result = hitTestResult.first {
           addHoop(result: result)
        }
        
    }
    
    func addHoop(result: ARHitTestResult) {
        let hoopScene = SCNScene(named: "art.scnassets/hoop.scn")
        guard let hoopNode = hoopScene?.rootNode.childNode(withName: "Hoop", recursively: true) else { return }
        
        let position = result.worldTransform.columns.3
        hoopNode.position = SCNVector3(position.x, position.y, position.z)
        
        sceneView.scene.rootNode.addChildNode(hoopNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .vertical
        
        
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func createWall(planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        
        
        let geometry = SCNPlane(width: width, height: height)
        
        let node = SCNNode()
        node.geometry = geometry
        
        node.eulerAngles.x = -Float.pi / 2
        node.opacity = 0.25
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let plainAnchor = anchor as? ARPlaneAnchor else { return }
        
        let floor = createWall(planeAnchor: plainAnchor)
        node.addChildNode(floor)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plainAnchor = anchor as? ARPlaneAnchor,
            let floor = node.childNodes.first,
            let geometry = floor.geometry as? SCNPlane
            else { return }
        
        geometry.width = CGFloat(plainAnchor.extent.x)
        geometry.height = CGFloat(plainAnchor.extent.z)
        
        floor.position = SCNVector3(plainAnchor.center.x, 0, plainAnchor.center.z)
        
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
