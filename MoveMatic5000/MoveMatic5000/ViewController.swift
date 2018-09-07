//
//  ViewController.swift
//  MoveMatic5000
//
//  Created by Robert Wiltshire on 06/09/2018.
//  Copyright © 2018 Robert Wiltshire. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, DeviceListenerDelegate {
    
    let deviceListener = DeviceListener()
    let pictureCapturer = PictureCapturer()
    
    @IBOutlet weak var backgroundImage: NSImageView!
    @IBOutlet weak var capturedImage: NSImageView!

    
    // ========== Counters =========
    var trackingCounters:[EmotionCount] = [EmotionCount(), EmotionCount(), EmotionCount()]
    var currentProduct = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startListeningForEvents()
        
        pictureCapturer.startCapture()
        
        displayImage(scenario: nil)
        
        writeAnalytics()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func displayImage(scenario : String?) {
        
        if currentProduct != 0 {
             playNotificationSound()
        } else {
            return
        }
        
        var imageName = "product\(currentProduct)"
        
        if scenario != nil {
            imageName.append("_\(scenario!)")
        }
        
        if let image = NSImage(named: NSImage.Name(imageName)) {
            backgroundImage.image = image
        }
    }
    
    func playNotificationSound() {
        NSSound(named: NSSound.Name("ding"))?.play()
    }
    
    func writeAnalytics() {
    
        let desktopURL = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = desktopURL.appendingPathComponent("MoveMatic5000_Analytics").appendingPathExtension("html")
        
        print("File Path: \(fileURL.path)")
        
        do {
            try self.analyticsHTML().write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Error: fileURL failed to write: \n\(error)" )
        }
    }
    
    func sendImageToAzure(imageToSend : NSImage) {
        
        // Create the URLSession on the default configuration
        let defaultSessionConfiguration = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultSessionConfiguration)
        
        // Setup the request with URL
        let url = URL(string: "https://northeurope.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceAttributes=emotion")!
        var urlRequest = URLRequest(url: url)
        
        // Convert POST string parameters to data using UTF8 Encoding
        let postData = imageToSend.tiffRepresentation
        
        // Set the httpMethod and assign httpBody
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        urlRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("af9088b970b146bab485fc19d698cdf0", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        // Create dataTask
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            // Handle your response here
            print("Response")
            self.parseResponse(data: data!)
        }
        
        // Fire the request
        dataTask.resume()
    }
    
    func parseResponse(data : Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [Any]
            
            guard json.count > 0 else {return}
            
            guard let faceAttributes =  (json[0] as! [String: Any])["faceAttributes"]  as? [String: Any] else {return}
            guard let emotion = faceAttributes["emotion"] as? [String: Double] else {return}
            
            let threashold = 0.5
            
            let happy = emotion["happiness"]! > threashold
            let sad = emotion["sadness"]! > threashold
            let neutral = emotion["neutral"]! > threashold
            let surprised = emotion["surprise"]! > threashold
            
            trackInteraction(happy: happy || neutral, sad: sad, surprised: surprised)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if happy {
                    self.displayImage(scenario: "happy")
                } else if sad {
                    self.displayImage(scenario: "sad")
                } else if surprised{
                    self.displayImage(scenario: "surprise")
                } else if neutral{
                    self.displayImage(scenario: "happy")
                } else {
                }
            }
            
            print(json)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func trackInteraction(happy : Bool, sad : Bool, surprised : Bool) {
        
        guard currentProduct > 0 else {return}
        
        if (happy) {
            trackingCounters[self.currentProduct-1].CountHappy += 1
        }
        if (sad) {
            trackingCounters[self.currentProduct-1].CountSad += 1
        }
        if (surprised) {
            trackingCounters[self.currentProduct-1].CountSurprised += 1
        }
        writeAnalytics()
    }
    
    func base64ImageRepresentation(imageData : NSData) -> String {
        //Now use image to create into NSData format    
        //let imageData:NSData = UIImagePNGRepresentation(image)!
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }
    
    func httpBody() -> String {
        return ""
    }
    func analyticsHTML() -> String {
        
        if let filepath = Bundle.main.path(forResource: "Analytics", ofType: "html") {
            do {
                var contents = try String(contentsOfFile: filepath)
                print(contents)
                
                // Replace contents here
                let emotionCountA = trackingCounters[0]
                let emotionCountB = trackingCounters[1]
                let emotionCountC = trackingCounters[2]
                
                contents = contents.replacingOccurrences(of: "[A_PICKUPS]", with: String(emotionCountA.total()))
                contents = contents.replacingOccurrences(of: "[A_SAD_PERCENT]", with: String(emotionCountA.percent(EmotionCount: emotionCountA.CountSad)))
                contents = contents.replacingOccurrences(of: "[A_HAPPY_PERCENT]", with: String(emotionCountA.percent(EmotionCount: emotionCountA.CountHappy)))
                contents = contents.replacingOccurrences(of: "[A_SURPRISED_PERCENT]", with: String(emotionCountA.percent(EmotionCount: emotionCountA.CountSurprised)))
                
                contents = contents.replacingOccurrences(of: "[B_PICKUPS]", with: String(emotionCountB.total()))
                contents = contents.replacingOccurrences(of: "[B_SAD_PERCENT]", with: String(emotionCountB.percent(EmotionCount: emotionCountB.CountSad)))
                contents = contents.replacingOccurrences(of: "[B_HAPPY_PERCENT]", with: String(emotionCountB.percent(EmotionCount: emotionCountB.CountHappy)))
                contents = contents.replacingOccurrences(of: "[B_SURPRISED_PERCENT]", with: String(emotionCountB.percent(EmotionCount: emotionCountB.CountSurprised)))
                
                contents = contents.replacingOccurrences(of: "[C_PICKUPS]", with: String(emotionCountC.total()))
                contents = contents.replacingOccurrences(of: "[C_SAD_PERCENT]", with: String(emotionCountC.percent(EmotionCount: emotionCountC.CountSad)))
                contents = contents.replacingOccurrences(of: "[C_HAPPY_PERCENT]", with: String(emotionCountC.percent(EmotionCount: emotionCountC.CountHappy)))
                contents = contents.replacingOccurrences(of: "[C_SURPRISED_PERCENT]", with: String(emotionCountC.percent(EmotionCount: emotionCountC.CountSurprised)))
                
                return contents
            } catch {
                print("fail")
            }
        } else {
            print("fail")
        }
        
        return ""
    }
    
    func startListeningForEvents() {
        deviceListener.delegate = self
        deviceListener.start()
    }
    
    //MARK: DeviceListenerDelegate
    
    func deviceListener(_ : DeviceListener, didReceiveLiftEventFromDevice id: Int) {
        capturedImage.image = pictureCapturer.lastCapturedImage
        self.currentProduct = id
        sendImageToAzure(imageToSend: self.capturedImage.image!)
        
        displayImage(scenario: nil)
    }
    
    
}


