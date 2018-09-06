//
//  ViewController.swift
//  InteractionDetector
//
//  Created by Raffaele La Brocca on 06/09/2018.
//  Copyright © 2018 HackatonTeam5. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let motion = CMMotionManager()
    var timer: Timer?
    
    var lastEventDate = Date.distantPast

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startAccelerometers()
       // sendMessage(id: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
            self.motion.startAccelerometerUpdates()
            
            // Configure a timer to fetch the data.
            self.timer = Timer(fire: Date(), interval: (1.0/60.0),
                               repeats: true, block: { (timer) in
                                // Get the accelerometer data.
                                if let data = self.motion.accelerometerData {
                                    let z = data.acceleration.z
                                    // print("--->\(z)")
                                    if z > -0.5 {
                                        if Date().timeIntervalSince(self.lastEventDate) > 5.0 {
                                            print("Lefted! ")
                                            self.sendMessage(id: 1)
                                            self.lastEventDate = Date()
                                        }
                                        
                                    }
                                    // Use the accelerometer data in your app.
                                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
        }
    }
    
    func sendMessage(id: Int) {
        let sessionWithoutADelegate = URLSession(configuration: URLSessionConfiguration.default)
        if let url = URL(string: "http://raffaeles-MacBook-Pro.local:8080/lift/1") {
            (sessionWithoutADelegate.dataTask(with: url) { (data, response, error) in
              
            }).resume()
        }
    }

}

