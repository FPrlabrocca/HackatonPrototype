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
    
    @IBOutlet weak var backgroundImage: NSImageCell!
    @IBOutlet weak var capturedImage: NSImageView!

    
    // ========== Counters =========
    var trackingCounters:[EmotionCount] = [EmotionCount(), EmotionCount(), EmotionCount()]
    var currentProduct = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startListeningForEvents()
        
        pictureCapturer.startCapture()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func displayImage(product : String, scenario : String) {
        let imageName = product + "_" + scenario
        let image : NSImage = NSImage(byReferencingFile: imageName)!
        backgroundImage.image = image
    }
    
    func writeAnalytics() {
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let fileName = "MoveMatic5000_Analytics.html"
        let downloadsDirectoryWithFile = downloadsDirectory.appendingPathComponent(fileName)
        let fileData = self.analyticsHTML().data(using: .utf8)
        
        let created = FileManager.default.createFile(atPath: downloadsDirectoryWithFile.absoluteString,
                                       contents: fileData,
                                       attributes: nil)
        print(created)
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
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            
            // Logic to figure out what to do here
            
            trackInteraction(happy: false, sad: false, surprised: false)
            
            print(json)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func trackInteraction(happy : Bool, sad : Bool, surprised : Bool) {
        if (happy) {
            trackingCounters[self.currentProduct].CountHappy += 1
        }
        else if (sad) {
            trackingCounters[self.currentProduct].CountSad += 1
        }
        else if (surprised) {
            trackingCounters[self.currentProduct].CountSurprised += 1
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
        // TODO
        return """
        <html>
        <head>
        </head>
        <body>
            <table>
                <tr>
                    <td><b>Product A</b></td>
                    <td><b>Product B</b></td>
                    <td><b>Product C</b></td>
                </tr>
                <tr>
        
                </tr>
            </table>
        </body>
        </html>
"""
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
    }
    
    
}


