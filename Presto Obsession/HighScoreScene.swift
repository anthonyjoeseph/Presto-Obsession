//
//  HighScoreScene.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/13/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation
import SpriteKit

class HighScoreScene:SKScene{
    
    fileprivate let scoreNode:SKLabelNode = SKLabelNode(fontNamed: "GothamBold")
    fileprivate let letters:[SKLabelNode] = [SKLabelNode(fontNamed: "GothamBold"), SKLabelNode(fontNamed: "GothamBold"), SKLabelNode(fontNamed: "GothamBold")]
    fileprivate var currentIndex:Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        initializeLabel(scoreNode)
        scoreNode.text = "HIGH SCORE!"
        scoreNode.position = CGPoint(x: self.size.width/2, y: self.size.height*0.75)
        addChild(scoreNode)
        
        for letter in self.letters {
            initializeLabel(letter)
            letter.text = "_"
            addChild(letter)
        }
        letters[0].position = CGPoint(x: self.size.width/2-letters[0].frame.width, y: self.size.height*0.25)
        letters[1].position = CGPoint(x: self.size.width/2, y: self.size.height*0.25)
        letters[2].position = CGPoint(x: self.size.width/2+letters[2].frame.width, y: self.size.height*0.25)
        flashCurrentLetter()
    }
    
    fileprivate func initializeLabel(_ label:SKLabelNode){
        label.fontColor = UIColor.white
        label.fontSize = 50
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
    }
    
    fileprivate func flashCurrentLetter(){
        if(self.currentIndex > 0){
            letters[self.currentIndex-1].removeAction(forKey: "flashAction")
            letters[self.currentIndex-1].isHidden = false
        }
        letters[self.currentIndex].run(SKAction.repeatForever(SKAction.sequence([SKAction.hide(), SKAction.wait(forDuration: 0.5) ,SKAction.unhide(), SKAction.wait(forDuration: 0.5)])), withKey: "flashAction")
    }
    
    func addLetter(_ newLetter:String){
        letters[self.currentIndex].text = newLetter
        self.currentIndex += 1
        if(self.currentIndex < 3){
            flashCurrentLetter()
        }
    }
    func nameFromLetters() -> String{
        let firstLetter:String = letters[0].text!
        let secondLetter:String = letters[1].text!
        let thirdLetter:String = letters[2].text!
        return firstLetter + secondLetter + thirdLetter
    }
}

