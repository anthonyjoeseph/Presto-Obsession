//
//  GameScene.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/12/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    
    let staffNode:AnimatedStaff
    fileprivate let noteZoneUnpressedTexture = SKTexture(imageNamed: "NoteZone")
    fileprivate let noteZonePressedTexture = SKTexture(imageNamed: "NoteZonePressed")
    fileprivate let noteZone:SKSpriteNode
    fileprivate let scoreNode:SKLabelNode = SKLabelNode(fontNamed: "GothamBold")
    fileprivate let highScoreNode:SKLabelNode = SKLabelNode(fontNamed: "GothamBold")
    
    required init?(coder aDecoder: NSCoder) {
        self.noteZone = SKSpriteNode(texture: self.noteZoneUnpressedTexture)
        self.staffNode = AnimatedStaff(size: CGSize(width: 0, height: 0))
        super.init()
    }
    
    override init(size: CGSize) {
        self.noteZone = SKSpriteNode(texture: self.noteZoneUnpressedTexture)
        self.staffNode = AnimatedStaff(size: CGSize(width: size.width, height: size.height/4))
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        staffNode.anchorPoint = CGPoint(x: 0, y: 0)
        staffNode.position = CGPoint(x: 0, y: size.height/4)
        staffNode.zPosition = 0.0
        
        noteZone.position = CGPoint(x: size.width/2, y: size.height/2)
        noteZone.zPosition = 2.0
        noteZone.anchorPoint = CGPoint(x: 0.5, y: 0.52)
        let currentNoteZoneHeight = noteZoneUnpressedTexture.size().height
        let desiredNoteZoneHeight = self.size.height * 0.95
        let heightScale = desiredNoteZoneHeight/currentNoteZoneHeight
        noteZone.xScale = heightScale
        noteZone.yScale = heightScale
        
        scoreNode.fontColor = UIColor.black
        scoreNode.fontSize = 50
        scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        scoreNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        scoreNode.position = CGPoint(
            x: self.size.width - (scoreNode.frame.width * 2 + 50),
            y: 100 + ((staffNode.size.height/2)+staffNode.position.y))
        
        highScoreNode.fontColor = UIColor.black
        highScoreNode.fontSize = 50
        highScoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        highScoreNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        highScoreNode.position = CGPoint(
            x: self.size.width - scoreNode.frame.width,
            y: 100 + ((staffNode.size.height/2)+staffNode.position.y))

        addChild(staffNode)
        addChild(noteZone)
        addChild(scoreNode)
        addChild(highScoreNode)
    }
    
    func pressNoteZone(){
        self.noteZone.texture = self.noteZonePressedTexture
    }
    
    func releaseNoteZone(){
        self.noteZone.texture = self.noteZoneUnpressedTexture
    }
    func noteZoneContainsPoint(_ p:CGPoint) -> Bool{
        return self.noteZone.contains(p)
    }
    
    func setScoreText(_ newScore:String){
        scoreNode.text = newScore
    }
    
    func setHighScoreText(_ newScore:String){
        scoreNode.text = newScore
    }
}
