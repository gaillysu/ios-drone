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
    let armOffsetFromBodyX = 9
    let armOffsetFromBodyY = 13
    
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
        leftArmNode.position = SCNVector3.init(-armOffsetFromBodyX, armOffsetFromBodyY, 0)
        
        let rightArm:SCNGeometry = SCNCylinder(radius: armRadius, height: armHeight)
        let rightArmNode = SCNNode(geometry: rightArm)
        bodyNode.addChildNode(rightArmNode)
        rightArmNode.position = SCNVector3.init(armOffsetFromBodyX, armOffsetFromBodyY, 0)
        
        let leftLeg:SCNGeometry = SCNCylinder(radius: legRadius, height: legHeight)
        let leftLegNode = SCNNode(geometry: leftLeg)
        bodyNode.addChildNode(leftLegNode)
        leftLegNode.position = SCNVector3.init(-legOffsetFromBodyX, -legOffsetFromBodyY, 0)
        
        let rightLeg:SCNGeometry = SCNCylinder(radius: legRadius, height: legHeight)
        let rightLegNode = SCNNode(geometry: rightLeg)
        bodyNode.addChildNode(rightLegNode)
        rightLegNode.position = SCNVector3.init(legOffsetFromBodyX, -legOffsetFromBodyY, 0)
        
        let head:SCNGeometry = SCNSphere(radius: headRadius)
        let headNode = SCNNode(geometry: head)
        bodyNode.addChildNode(headNode)
        headNode.position =  SCNVector3.init(0, 20, 0)
        self.addChildNode(bodyNode)
        
        self.bodyNode = bodyNode
        
        self.leftLegNode = leftLegNode
        self.rightLegNode = rightLegNode
        
        self.leftArmNode = leftArmNode
        self.rightArmNode = rightArmNode
        self.leftArmNode?.pivot = SCNMatrix4MakeTranslation(0.0, Float(CGFloat(armHeight/2)), 0.0)
        self.rightArmNode?.pivot = SCNMatrix4MakeTranslation(0.0, Float(CGFloat(armHeight/2)), 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func rotateNode(node:SCNNode, x:CGFloat, y:CGFloat, z:CGFloat = 0.0){
        reset(node: node)
        //instead of y:0.0, 0.o should be computedZ
        node.runAction(SCNAction.rotateBy(x: x, y: y, z: z, duration: 0.0))
        // So X  is Up Down movement, Z is left right movement on the dummy.
        // Range for the movement is [-6.285...6.285]. So from [0.0...6.285] its CCW/CW and [-6.285...0.0] its CW/CCW
    }
    
    func reset(node:SCNNode){
        node.runAction(SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0, duration: 0.0))
    }
    
    func rotateLeftLeg(x:CGFloat, y:CGFloat, z:CGFloat){
        if let node = self.leftLegNode{
            rotateNode(node: node, x: getCoordinatesForHuman(one: x), y: getCoordinatesForHuman(one: y), z:getCoordinatesForHuman(one: z))
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
    
    func rotateLeftArm(x:CGFloat, y:CGFloat, z:CGFloat = 0.0){
        if let node = self.leftArmNode{
            rotateNode(node: node, x: x, y: y, z: z)
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
    private func getCoordinatesForHuman(one:CGFloat) -> CGFloat{
        var outcome:CGFloat = CGFloat((6.285/512.0) * one)
        if one < 0.0 {
            outcome = outcome * -1
        }
        return outcome
        
    }
}
