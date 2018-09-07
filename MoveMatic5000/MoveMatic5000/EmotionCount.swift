//
//  EmotionCount.swift
//  MoveMatic5000
//
//  Created by Robert Wiltshire on 07/09/2018.
//  Copyright © 2018 Robert Wiltshire. All rights reserved.
//

import Cocoa

class EmotionCount: NSObject {
    var CountHappy = 0
    var CountSad = 0
    var CountSurprised = 0
    var CountNeutral = 0
    
    func percentHappy(EmotionCount : Int) -> Int {
        let percent : Int = (EmotionCount / (CountHappy + CountSad + CountSurprised + CountNeutral)) * 100
        return percent
    }
    
    func total() -> Int {
        return CountHappy + CountSad + CountSurprised + CountNeutral
    }
}
