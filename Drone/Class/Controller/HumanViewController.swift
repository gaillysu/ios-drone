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

    override func viewDidLoad() {
        super.viewDidLoad()
        scnView = self.view as! SCNView
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "Human.scnassets/Background_Diffuse.png"
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 1
        camera.zNear = 0
        camera.zFar = 0
        cameraNode = SCNNode()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        cameraNode.camera = camera
        let cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
//        scnScene.rootNode.addChildNode(cameraOrbit)
        
        cameraOrbit.eulerAngles.x -= Float(M_PI_4/2)
//        let humanScene = (SCNScene(named: "Human.scnassets/FinalBaseMesh.scn")!).rootNode
        scnScene.rootNode.addChildNode(Human())
//        let lumberJack = humanScene.childNodes[0]
//        print(lumberJack.name!)
//        let childNodes = lumberJack.childNodes
//        let actions = lumberJack.actionKeys
//        let animationKeys = lumberJack.animationKeys
        
        
        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
}
