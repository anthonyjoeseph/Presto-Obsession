//
//  CountdownView.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/12/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import UIKit
import Foundation


class CountdownView: UIView{
    
    @IBOutlet var countdownTimerImage:UIImageView?
 
    fileprivate var countdownTimer:Timer?
    fileprivate var countdownTimerCount = 3
    fileprivate let countdownImageTwo:UIImage = UIImage(named: "countdown2")!
    fileprivate let countdownImageOne:UIImage = UIImage(named: "countdown1")!
    
    var timerOverFunc: (Void) -> Void = {}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CountdownView.countdownTimerTick), userInfo: nil, repeats: true)
    }
    
    @objc func countdownTimerTick(){
        if self.countdownTimerCount == 2 {
            self.countdownTimerImage?.image = self.countdownImageTwo
        }else if self.countdownTimerCount == 1 {
            self.countdownTimerImage?.image = self.countdownImageOne
        }else if self.countdownTimerCount <= 0{
            self.timerOverFunc()
            self.countdownTimerImage?.isHidden = true
            self.countdownTimer!.invalidate()
            self.countdownTimer = nil
        }
        self.countdownTimerCount -= 1
    }
}
