//
//  ViewController.swift
//  Planetarium
//
//  Created by MacMini3 on 12/09/18.
//  Copyright © 2018 MacMini3. All rights reserved.
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //Set plane detection to horizontal to detect horizontal places
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            //to get the place where we touched on 2D screen
            let touchLocation = touch.location(in: sceneView)
            
            //hitTest is used to detect the 3D coordinated corresponding to the 2D coordinates that we got from touching the screen
            //That 3D coordinates will only be considered when it is on the existing plane which we detected.
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            //if we get any results which means we tapped on the plane, perform this,
            if let hitResults = results.first {
                
                let boxScene = SCNScene(named: "art.scnassets/solarSystem.scn")
                
                if let boxNode = boxScene?.rootNode.childNode(withName: "solarSystem", recursively: true) {
                    
                    boxNode.position = SCNVector3(
                        x: hitResults.worldTransform.columns.3.x,
                        y: hitResults.worldTransform.columns.3.y + 0.15,
                        z: hitResults.worldTransform.columns.3.z
                    )
                    
                    //add the box to the scene
                    sceneView.scene.rootNode.addChildNode(boxNode)
                }
            }
            
        }
    }
    
    //This is delegate method which is from ARSCNViewDelegate, this method is called when the horizontal plane detected.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor {
            
            //anchor can be many types, as we are just dealing with horizontal plane detection we need to downcast anchor to ARPlanceAnchor
            let planeAnchor = anchor as! ARPlaneAnchor
            
            //creating a plane geometry with the help of dimentions we got using plane anchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            //node is basically a position
            let planeNode = SCNNode()
            
            //set the position of the plane geometry to the position we got from planeAnchor
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            
            //when a plane is created, by default it created in xy plane instead of xz plane, SO we need to rotate it along with x axis
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            //create a material object to apply on the horizontal plane
            let gridMaterial = SCNMaterial()
            
            //Give color to the material
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            //Assigning the material tot he plane
            plane.materials = [gridMaterial]
            
            //assigning the position to the plane
            planeNode.geometry = plane
            
            //add the plane node in our scene
            node.addChildNode(planeNode)
        }
        else {
            return
        }
    }
}
