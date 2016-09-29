//
//  HumanViewController.swift
//  Drone
//
//  Created by Karl Chow on 9/28/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class HumanViewController: BaseViewController {

    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var human:Human?
    override func viewDidLoad() {
        super.viewDidLoad()
        scnView = self.view as! SCNView
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "Human.scnassets/Background_Diffuse.png"
        // 1
        cameraNode = SCNNode()
        // 2
        cameraNode.camera = SCNCamera()
        // 3
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 70)
        // 4
        scnScene.rootNode.addChildNode(cameraNode)
        self.human = Human()
        scnScene.rootNode.addChildNode(human!)

        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true
    }
    
    @IBAction func leftLegAction(_ sender: AnyObject) {
        print("Test1")
        human?.rotateLeftLeg(x: 10.0, y: 10.0)
    }
    
    @IBAction func rightLegAction(_ sender: AnyObject) {
        print("Test2")
        human?.rotateRightLeg(x: 10.0, y: 10.0)
    }
    
    @IBAction func leftArmAction(_ sender: AnyObject) {
        print("Test3")
        human?.rotateLeftArm(x: 10.0, y: 10.0)
    }
    
    @IBAction func rightArmAction(_ sender: AnyObject) {
        print("Test4")
        human?.rotateRightArm(x: 10.0, y: 10.0)
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
}
