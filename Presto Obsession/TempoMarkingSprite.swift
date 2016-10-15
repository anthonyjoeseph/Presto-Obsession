//
//  TempoMarkingSprite.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/29/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation
import SpriteKit

class TempoMarkingSprite:SKSpriteNode, StaffElementNode{
    
    fileprivate static let tempoXPosLedgerLines:CGFloat = 4
    
    init(tempoMarking:Int){
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: 1, height: 1))
        
        let qNoteSprite = NoteSprite(
            note: Note(pitch: Pitch(absolutePitch: 0), rhythm: Rhythm.quarter),
            incrementsFromMiddle: 0,
            ledgerLines: nil)
        qNoteSprite.addStem(true)
        qNoteSprite.position = CGPoint(x: 0, y: 0)
        self.addChild(qNoteSprite)
        
        let tempoLabel:SKLabelNode = SKLabelNode(fontNamed: "GothamBold")
        tempoLabel.text = "= " + String(tempoMarking)
        tempoLabel.fontColor = UIColor.black
        tempoLabel.fontSize = 30
        tempoLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        tempoLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        tempoLabel.position = CGPoint(x: qNoteSprite.size.width, y: 0)
        self.addChild(tempoLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func positionOnStaff(_ staffSize: CGSize, ledgerLineSpace: CGFloat) -> CGPoint{
        let middlePosition = staffSize.height/2
        return CGPoint(x: TempoMarkingSprite.tempoXPosLedgerLines*ledgerLineSpace, y: middlePosition + (ledgerLineSpace * 5))
    }
    
    func acceptStaffDimensions(_ staffSize:CGSize, ledgerLineSpace:CGFloat){
        //do nothing
    }
    
    func onePerStaff() -> Bool{
        return true
    }
    
    func staffElementType() -> StaffElementType{
        return StaffElementType.tempoMarking
    }
    
    func hasMidPointWhenAnimating() -> Bool{
        return false
    }
}
