//
//  AnimatedStaff.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation
import SpriteKit

class AnimatedStaff: SKSpriteNode {
    
    private var ledgerLineSpace:CGFloat = 0.0
    private var staffTexture = SKTexture(imageNamed: "Music-Staff")
    private var currentKeySignatureSprite:KeySignatureSprite? = nil
    private var currentClefSprite:SKSpriteNode? = nil
    private var currentTempoMarkingSprite:SKSpriteNode? = nil
    private var noteSprites:Set<NoteSprite> = Set()
    private var uniqueStaffElementNodes:[StaffElementType:StaffElementNode] = [:]
    private var notes:[StaffElementNode] = []
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    init(size:CGSize){
        super.init(texture: self.staffTexture, color: UIColor.clear, size: size)
        
        self.ledgerLineSpace = self.size.height * 0.245
    }
    
    func currentNoteSprites() -> Set<NoteSprite>{
        return noteSprites
    }
    
    func removeNoteSprite(_ removeNode:NoteSprite){
        noteSprites.remove(removeNode)
        removeNode.removeFromParent()
    }
    
    
    func placeStaffElementNode(_ staffElementNode:StaffElementNode){
        introduceToStaff(staffElementNode)
        internalPlaceStaffElementNode(staffElementNode)
    }
    
    func animateStaffElementNode(
        _ staffElementNode:StaffElementNode,
        pixelsPerSecond:Double,
        midFunc:((Void) -> Void)?,
        endFunc:((Void) -> Void)?){
        
        introduceToStaff(staffElementNode)
        placeStaffElementBeforeAnimating(staffElementNode)
        var midPosition:CGPoint?
        let endPosition = staffElementNode.positionOnStaff(self.size, ledgerLineSpace: self.ledgerLineSpace)
        var internalMidFunc:((Void) -> Void)?
        var internalEndFunc:((Void) -> Void)
        switch(staffElementNode.staffElementType()){
        case StaffElementType.note:
            let asNoteSprite = staffElementNode as! NoteSprite
            internalEndFunc = {
                endFunc!()
                asNoteSprite.removeFromParent()
            }
            self.noteSprites.insert(asNoteSprite)
            break
        case StaffElementType.keySignature:
            let asKeySig = staffElementNode as! KeySignatureSprite
            let courtesyKeySigPadding = asKeySig.getCourtesyKeySigPadding()!
            midPosition = CGPoint(x: endPosition.x + courtesyKeySigPadding, y: endPosition.y )
            internalMidFunc = {
                self.removeCurrentStaffElementNode(staffElementNode.staffElementType())
                asKeySig.removeCourtesyKeySig()
            }
            internalEndFunc = {
                self.internalPlaceStaffElementNode(asKeySig)
            }
            break
        case StaffElementType.clef:
            let asClefSprite = staffElementNode as! ClefSprite
            midPosition = CGPoint(x: self.size.width/2, y: endPosition.y)
            internalMidFunc = {
                midFunc!()
            }
            internalEndFunc = {
                endFunc!()
                self.internalPlaceStaffElementNode(asClefSprite)
            }
            break
        case StaffElementType.tempoMarking:
            let asTempoMarking = staffElementNode as! TempoMarkingSprite
            internalEndFunc = {
                self.internalPlaceStaffElementNode(asTempoMarking)
            }
            break
        }
        if(staffElementNode.hasMidPointWhenAnimating()){
            animateSpriteAcrossStaffMidPoint(
                staffElementNode as! SKSpriteNode,
                midPosition: midPosition!, endPosition: endPosition,
                pixelsPerSecond: pixelsPerSecond,
                midFunc: internalMidFunc!, endFunc:internalEndFunc)
        }else{
            animateSpriteAcrossStaff(
                staffElementNode as! SKSpriteNode,
                endPosition: endPosition,
                pixelsPerSecond: pixelsPerSecond,
                endFunc: internalEndFunc)
        }
    }
    
    fileprivate func introduceToStaff(_ staffElementNode:StaffElementNode){
        staffElementNode.acceptStaffDimensions(self.size, ledgerLineSpace: self.ledgerLineSpace)
        addChild(staffElementNode as! SKSpriteNode)
    }
    
    fileprivate func removeCurrentStaffElementNode(_ staffElementType:StaffElementType){
        if uniqueStaffElementNodes[staffElementType] != nil{
            let skNodeElement = uniqueStaffElementNodes[staffElementType] as! SKSpriteNode
            skNodeElement.removeFromParent()
        }
    }
    
    fileprivate func internalPlaceStaffElementNode(_ staffElementNode:StaffElementNode){
        if(staffElementNode.onePerStaff()){
            removeCurrentStaffElementNode(staffElementNode.staffElementType())
            uniqueStaffElementNodes[staffElementNode.staffElementType()] = staffElementNode
        }else{
            notes.append(staffElementNode)
        }
        
        let spriteStaffElementNode = staffElementNode as! SKSpriteNode
        spriteStaffElementNode.position = staffElementNode.positionOnStaff(self.size, ledgerLineSpace: self.ledgerLineSpace)
    }
    
    fileprivate func placeStaffElementBeforeAnimating(_ staffElementNode:StaffElementNode){
        let staffElementNodeAsSprite = staffElementNode as! SKSpriteNode
        let endPosition = staffElementNode.positionOnStaff(self.size, ledgerLineSpace: self.ledgerLineSpace)
        let xToRightOfStaff = size.width+(staffElementNodeAsSprite.calculateAccumulatedFrame().width/2)
        staffElementNodeAsSprite.position = CGPoint(x: xToRightOfStaff, y: endPosition.y)
    }
    
    fileprivate func animateSpriteAcrossStaff(_ sprite:SKSpriteNode, endPosition:CGPoint, pixelsPerSecond:Double, endFunc:@escaping (Void) -> Void){
        let distance = sprite.position.x - endPosition.x
        let timeToReachEndPoint:TimeInterval = TimeInterval(CGFloat((1/pixelsPerSecond)) * distance)
        let actionMove = SKAction.move(
            to: endPosition,
            duration: timeToReachEndPoint)
        let actionMoveDone = SKAction.run(endFunc)
        sprite.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    fileprivate func animateSpriteAcrossStaffMidPoint(_ sprite:SKSpriteNode, midPosition:CGPoint, endPosition:CGPoint, pixelsPerSecond:Double, midFunc: @escaping (Void)->(Void), endFunc:@escaping (Void) -> Void){
        animateSpriteAcrossStaff(sprite, endPosition: midPosition, pixelsPerSecond: pixelsPerSecond, endFunc: {
            midFunc()
            self.animateSpriteAcrossStaff(sprite, endPosition: endPosition, pixelsPerSecond: pixelsPerSecond, endFunc: endFunc)
        })
    }
}
