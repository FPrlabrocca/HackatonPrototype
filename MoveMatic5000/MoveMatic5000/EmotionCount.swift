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
    
    func percent(EmotionCount : Int) -> Int {
        var percent : Double = 0
        if (total() > 0 && EmotionCount > 0) {
            percent = (Double(EmotionCount) / Double(total())) * 100
        }
        
        return Int(percent)
    }
    
    func total() -> Int {
        return CountHappy + CountSad + CountSurprised
    }
}
