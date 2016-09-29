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

    private let headRadius = CGFloat(5)
    private let headYOffset = CGFloat(5)
    
    let bodyRadius = CGFloat(6)
    let bodyHeight = CGFloat(25)
    
    let armRadius = CGFloat(3)
    let armHeight = CGFloat(15)
    let armOffsetFromBody = 19
    
    let legRadius = CGFloat(3)
    let legHeight = CGFloat(15)
    let legOffsetFromBodyX = 5
    let legOffsetFromBodyY = 17
    
    var headNode:SCNNode?
    var bodyNode:SCNNode?
    
    var leftArmNode:SCNNode?
    var rightArmNode:SCNNode?
    
    var leftLegNode:SCNNode?
    var rightLegNode:SCNNode?
    
    override init() {
        super.init()
        let body:SCNGeometry = SCNCylinder(radius: bodyRadius, height: bodyHeight)
        let bodyNode = SCNNode(geometry: body)

        let leftArm:SCNGeometry = SCNCylinder(radius: armRadius, height: armHeight)
        let leftArmNode = SCNNode(geometry: leftArm)
        bodyNode.addChildNode(leftArmNode)
        leftArmNode.runAction(SCNAction.move(to: SCNVector3.init(-armOffsetFromBody, 10, 0), duration: 0.5))
        
        let rightArm:SCNGeometry = SCNCylinder(radius: armRadius, height: armHeight)
        let rightArmNode = SCNNode(geometry: rightArm)
        bodyNode.addChildNode(rightArmNode)
        rightArmNode.runAction(SCNAction.move(to: SCNVector3.init(armOffsetFromBody, 10, 0), duration: 0.5))
        
        let leftLeg:SCNGeometry = SCNCylinder(radius: legRadius, height: legHeight)
        let leftLegNode = SCNNode(geometry: leftLeg)
        bodyNode.addChildNode(leftLegNode)
        leftLegNode.runAction(SCNAction.move(to: SCNVector3.init(-legOffsetFromBodyX, -legOffsetFromBodyY, 0), duration: 0.5))
        
        let rightLeg:SCNGeometry = SCNCylinder(radius: legRadius, height: legHeight)
        let rightLegNode = SCNNode(geometry: rightLeg)
        bodyNode.addChildNode(rightLegNode)
        rightLegNode.runAction(SCNAction.move(to: SCNVector3.init(legOffsetFromBodyX, -legOffsetFromBodyY, 0), duration: 0.5))
        
        let head:SCNGeometry = SCNSphere(radius: headRadius)
        let headNode = SCNNode(geometry: head)
        bodyNode.addChildNode(headNode)
        headNode.runAction(SCNAction.move(to: SCNVector3.init(0, 20, 0), duration: 0.5))
        self.addChildNode(bodyNode)
        
        self.bodyNode = bodyNode
        self.leftLegNode = leftLegNode
        self.rightLegNode = rightLegNode
        self.leftArmNode = leftArmNode
        self.rightArmNode = rightArmNode
//        self.rightArmNode?.position = SCNVector3.init(-10.0, -10.0, 0.0)
        
//        self.rightArmNode?.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0)
//        self.leftArmNode?.position = SCNVector3.init(-10.0, -10.0, 0.0)
        print(self.leftArmNode?.position.x)
        print(self.leftArmNode?.position.y)
        print(self.leftArmNode?.position.z)
        self.leftArmNode?.pivot = SCNMatrix4MakeTranslation(-10.0,0.0, 0.0)
        print("LOololol")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func rotateNode(node:SCNNode, x:CGFloat, y:CGFloat){
        node.runAction(SCNAction.rotateTo(x: 0.0, y: 0.0, z: 5.0, duration: 10.0))
    }
    
    func rotateLeftLeg(x:CGFloat, y:CGFloat){
        if let node = self.leftLegNode{
            rotateNode(node: node, x: x, y: y)
        }else{
            print("Something is not right into the code!")
        }
    }
    
    func rotateRightLeg(x:CGFloat, y:CGFloat){
        if let node = self.rightLegNode{
            rotateNode(node: node, x: x, y: y)
        }else{
            print("Something is not right into the code!")
        }
    }
    
    func rotateLeftArm(x:CGFloat, y:CGFloat){
        if let node = self.leftArmNode{
            rotateNode(node: node, x: x, y: y)
        }else{
            print("Something is not right into the code!")
        }
    }
    
    func rotateRightArm(x:CGFloat, y:CGFloat){
        if let node = self.rightArmNode{
            rotateNode(node: node, x: x, y: y)
        }else{
            print("Something is not right into the code!")
        }
    }
}
