//
//  Human.swift
//  Drone
//
//  Created by Karl Chow on 9/28/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import SceneKit


// 1
class Human:SCNNode {

    let bodyRadius = CGFloat(10)
    let bodyHeight = CGFloat(20)
    let armRadius = CGFloat(3)
    let armHeight = CGFloat(15)
    let armOffsetFromBody = 13
    let legRadius = CGFloat(3)
    let legHeight = CGFloat(15)
    let legOffsetFromBodyX = 10
    let legOffsetFromBodyY = 15
    
    override init() {
        super.init()
        let body:SCNGeometry = SCNCylinder(radius: bodyRadius, height: bodyHeight)
        let bodyNode = SCNNode(geometry: body)
        let leftArm:SCNGeometry = SCNCylinder(radius: armRadius, height: armHeight)
        let leftArmNode = SCNNode(geometry: leftArm)
        bodyNode.addChildNode(leftArmNode)
        leftArmNode.runAction(SCNAction.move(to: SCNVector3.init(-armOffsetFromBody, 0, 0), duration: 0.5))
        
        let rightArm:SCNGeometry = SCNCylinder(radius: armRadius, height: armHeight)
        let rightArmNode = SCNNode(geometry: rightArm)
        bodyNode.addChildNode(rightArmNode)
        rightArmNode.runAction(SCNAction.move(to: SCNVector3.init(armOffsetFromBody, 0, 0), duration: 0.5))
        
        let leftLeg:SCNGeometry = SCNCylinder(radius: legRadius, height: legHeight)
        let leftLegNode = SCNNode(geometry: leftLeg)
        bodyNode.addChildNode(leftLegNode)
        leftLegNode.runAction(SCNAction.move(to: SCNVector3.init(-legOffsetFromBodyX, -legOffsetFromBodyY, 0), duration: 0.5))
        
        let rightLeg:SCNGeometry = SCNCylinder(radius: legRadius, height: legHeight)
        let rightLegNode = SCNNode(geometry: rightLeg)
        bodyNode.addChildNode(rightLegNode)
        rightLegNode.runAction(SCNAction.move(to: SCNVector3.init(legOffsetFromBodyX, -legOffsetFromBodyY, 0), duration: 0.5))
        
        self.addChildNode(bodyNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
