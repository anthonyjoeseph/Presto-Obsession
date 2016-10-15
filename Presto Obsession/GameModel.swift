//
//  GameModel.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/29/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

enum GameElement{
    case note, clef, keySignature, tempo
}

enum DifficultyLevel{
    case beginner, intermediate, expert
}

class GameModel: NSObject{
    static let trebleKeyRange:KeyRange = KeyRange(lowPitch: Pitch(absolutePitch: 39), highPitch: Pitch(absolutePitch: 54))
    static let bassKeyRange:KeyRange = KeyRange(lowPitch: Pitch(absolutePitch: 27), highPitch: Pitch(absolutePitch: 42))
    static let defaultBPM:Int = 60
    static let secondsInMinute:Int = 60
    
    fileprivate var difficultyLevel:DifficultyLevel
    fileprivate var score:Int{
        didSet {
            if(self.score > self.highScore){
                self.highScore = self.score
                self.gamePersistence.updateHighScore(self.highScore)
                self.highScoreUpdated()
            }
            self.scoreUpdated()
        }
    }
    fileprivate var highScore:Int
    var currentTimer:Timer = Timer()
    
    fileprivate let gamePersistence:GamePersistence
    var gameCountState:GameCountStateMachine = GameCountStateMachine(difficultyLevel: DifficultyLevel.beginner)
    var musicElements:MusicElements
    
    var updateStaffWithGameElement:(GameElement) -> Void
    var areNotesCleared: (Void) -> Bool
    var scoreUpdated: (Void) -> Void
    var highScoreUpdated: (Void) -> Void
    
    convenience override init(){
        self.init(difficultyLevel: DifficultyLevel.beginner, updateStaffWithGameElement: {(GameElement)->Void in}, areNotesCleared: {(Void) -> Bool in return true}, scoreUpdated: {}, highScoreUpdated: {})
    }
    
    init(difficultyLevel:DifficultyLevel, updateStaffWithGameElement:@escaping (GameElement) -> Void, areNotesCleared: @escaping (Void) -> Bool, scoreUpdated: @escaping (Void) -> Void, highScoreUpdated: @escaping (Void) -> Void){
        self.updateStaffWithGameElement = updateStaffWithGameElement
        self.areNotesCleared = areNotesCleared
        self.scoreUpdated = scoreUpdated
        self.highScoreUpdated = highScoreUpdated
        
        self.difficultyLevel = difficultyLevel
        gameCountState = GameCountStateMachine(difficultyLevel: self.difficultyLevel)
        gameCountState.areNotesCleared = self.areNotesCleared
        self.musicElements = MusicElements(difficultyLevel: self.difficultyLevel)
        
        self.gamePersistence = GamePersistence()
        self.score = 0
        self.highScore = self.gamePersistence.savedHighScore()
        
        super.init()
    }
    
    func update(){
        if(!self.gameCountState.isWaiting()){
            let newGameElement = self.gameCountState.pickNewElement()
            switch(newGameElement){
            case GameElement.clef:
                self.musicElements.changeClef()
                break
            case GameElement.keySignature:
                self.musicElements.changeKeySignature()
                break
            case GameElement.tempo:
                self.musicElements.increaseBPM()
                self.resetTimer()
                break
            default:
                break
            }
            self.updateStaffWithGameElement(newGameElement)
        }
        self.gameCountState.updateCycle()
    }
    
    func resetTimer(){
        self.currentTimer.invalidate()
        let timeBetweenBeats:Double = Double(GameModel.secondsInMinute)/Double(self.musicElements.currentBPM)
        self.currentTimer = Timer.scheduledTimer(timeInterval: timeBetweenBeats, target: self, selector: #selector(GameModel.update), userInfo: nil, repeats: true)
        update()
    }
    func stopTimer(){
        self.currentTimer.invalidate()
    }
    
    func getScore() -> Int{
        return score
    }
    func getHighScore() -> Int{
        return highScore
    }
    func updateScoreWithCorrectNote(){
        switch(self.difficultyLevel){
        case DifficultyLevel.beginner:
            score += 100
            break
        case DifficultyLevel.intermediate:
            score += 200
            break
        case DifficultyLevel.expert:
            score += 1000
            break
        }
    }
    func updateScoreWithIncorrectNote(){
        score -= 10
    }
}
