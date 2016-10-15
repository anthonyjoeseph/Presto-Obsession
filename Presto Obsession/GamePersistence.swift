//
//  GamePersistence.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 1/12/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GamePersistence{
    
    //stored highest first, lowest last
    fileprivate let userDefaults = UserDefaults.standard
    fileprivate static let HIGHSCOREKEY = "HighScore"
    fileprivate static let HIGHSCORESKEY = "HighScores"
    fileprivate static let HIGHSCORESNAMESKEY = "HighScoreNames"
    fileprivate static let maxNumHighScores = 10
    
    func savedHighScore() -> Int{
        let highScore:Int
        if let savedHighScore = self.userDefaults.value(forKey: GamePersistence.HIGHSCOREKEY) {
            highScore = savedHighScore as! Int
        }else{
            highScore = 0
        }
        return highScore
    }
    
    func updateHighScore(_ newHighScore:Int){
        userDefaults.setValue(newHighScore, forKey: GamePersistence.HIGHSCOREKEY)
    }
    
    //returns true if is a new high score
    func storeNewScore(_ score:Int, name:String) -> Bool{
        var highScores:Array<Int>
        var isHighScore:Bool
        
        if let savedHighScores = self.highScores() {
            highScores = savedHighScores
            if(score > highScores.last || highScores.count < 8){
                highScores.append(score)
                highScores.sort(by: >)
                if(highScores.count > 8){
                    highScores.removeLast()
                }
                isHighScore = true
            }else{
                isHighScore = false
            }
        }else{
            highScores = [score]
            isHighScore = true
        }
        if(isHighScore){
            userDefaults.setValue(highScores as NSArray, forKey: GamePersistence.HIGHSCORESKEY)
            var highScoreNames:Dictionary<Int, String>
            if let savedHighScoreNames = scoreNames(){
                highScoreNames = savedHighScoreNames
            }else{
                highScoreNames = Dictionary<Int, String>()
            }
            highScoreNames[score] = name
            //NSDictionaries can't have primitive keys, so the integer keys must be converted to strings
            var highScoreNamesConvertable:Dictionary = Dictionary<NSString, NSString>()
            for (key, value) in highScoreNames {
                let nsKey = String(key) as NSString
                let nsValue = value as NSString
                highScoreNamesConvertable[nsKey] = nsValue
            }
            userDefaults.setValue(highScoreNamesConvertable as NSDictionary, forKey: GamePersistence.HIGHSCORESNAMESKEY)
            
        }
        userDefaults.synchronize()
        
        return isHighScore
    }
    
    func highScores() -> Array<Int>?{
        let highScoresAnyOp = userDefaults.value(forKey: "HighScores")
        if let highScoresAny = highScoresAnyOp{
            let highScoresNS = highScoresAny as! NSArray
            var highScores = [Int]()
            for scoreAny in highScoresNS {
                let score:Int = scoreAny as! Int
                highScores.append(score)
            }
            return highScores
        }
        return nil
    }
    
    func scoreNames() -> Dictionary<Int, String>?{
        let highScoreNamesAnyOp = userDefaults.value(forKey: "HighScoreNames")
        if let highScoreNamesAny = highScoreNamesAnyOp{
            let highScoreNamesNS = highScoreNamesAny as! NSDictionary
            var highScoreNames:Dictionary = [Int : String]()
            for (key, value) in highScoreNamesNS {
                let keyAsInt:Int = (key as! NSString).integerValue
                let valueAsString:String = (value as! NSString) as String
                highScoreNames[keyAsInt] = valueAsString
            }
            return highScoreNames
        }
        return nil
    }
    func resetScores(){
        let domainName = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domainName)
    }
    func isHighScore(_ newScore:Int) -> Bool{
        let highScores = self.highScores()
        return (newScore > highScores?.last || highScores?.count < 8)
    }
}
