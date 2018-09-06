//
//  DeviceListener.swift
//  MoveMatic5000
//
//  Created by Raffaele La Brocca on 06/09/2018.
//  Copyright © 2018 Robert Wiltshire. All rights reserved.
//

import Cocoa
import Embassy

protocol DeviceListenerDelegate: class {
    func deviceListener(_ : DeviceListener, didReceiveLiftEventFromDevice id: Int)
}

class DeviceListener: NSObject {

    weak var delegate: DeviceListenerDelegate?
    
    
    func start() {
        
        let server: DefaultHTTPServer
        let loop: SelectorEventLoop
        
        loop = try! SelectorEventLoop(selector: try! KqueueSelector())
        server = DefaultHTTPServer(eventLoop: loop, interface: "0.0.0.0", port: 8080) {
            (
            environ: [String: Any],
            startResponse: ((String, [(String, String)]) -> Void),
            sendBody: ((Data) -> Void)
            ) in
            // Start HTTP response
            startResponse("200 OK", [])
            let pathInfo = environ["PATH_INFO"]! as! String
            
            if pathInfo.lowercased().starts(with: "/lift/") {
                if let id = Int(pathInfo.split(separator: "/").last!) {
                    self.delegate?.deviceListener(self, didReceiveLiftEventFromDevice: id)
                    sendBody(Data("Got it: device \(id) lifted".utf8))
                } else {
                    sendBody(Data("Invalid device id".utf8))
                }
            } else {
                sendBody(Data("Command not recognised".utf8))
            }
            
            // send EOF
            sendBody(Data())
        }
        
        DispatchQueue.main.async {
            // Start HTTP server to listen on the port
            try! server.start()
            
            // Run event loop
            loop.runForever()
        }
    }

}
