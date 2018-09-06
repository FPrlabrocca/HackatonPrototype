//
//  ViewController.swift
//  InteractionDetector
//
//  Created by Raffaele La Brocca on 06/09/2018.
//  Copyright © 2018 HackatonTeam5. All rights reserved.
//

import UIKit
import CoreMotion
import SocketIO

class ViewController: UIViewController {
    
    let motion = CMMotionManager()
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startAccelerometers()
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
                                        print("Lefted! ")
                                        self.sendMessage(id: 1)
                                    }
                                    // Use the accelerometer data in your app.
                                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
        }
    }
    
    func sendMessage(id: Int) {
        let manager = SocketManager(socketURL: URL(string: "http://10.10.1.120:8080")!, config: [.log(true)])
        let socket = manager.defaultSocket
        socket.connect()
        socket.emit("productLifted", ["id":1])
    }

}

