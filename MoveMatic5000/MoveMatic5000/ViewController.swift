//
//  ViewController.swift
//  MoveMatic5000
//
//  Created by Robert Wiltshire on 06/09/2018.
//  Copyright © 2018 Robert Wiltshire. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        sendImageToAzure()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    func sendImageToAzure() {
        
        // Create the URLSession on the default configuration
        let defaultSessionConfiguration = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultSessionConfiguration)
        
        // Setup the request with URL
        let url = URL(string: "https://northeurope.api.cognitive.microsoft.com/face/v1.0/detect")!
        var urlRequest = URLRequest(url: url)
        
        // Convert POST string parameters to data using UTF8 Encoding
        let postData = httpBody().data(using: .utf8)
        //TODO //body = body.replacingOccurrences(of: "[_IMAGEDATA_]", with: self.base64ImageRepresentation(PASS IMAGE IN HERE))
        
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
            
            print(json)
        } catch let error as NSError {
            print(error)
        }
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
    
}


