//
//  LocationSocket.swift
//  App
//
//  Created by Green, Jonathan on 7/16/18.
//

import Foundation
import Vapor
final class LocationSocket {
    var socks:[WebSocket] = []
    var drop:Droplet?
    init(drop:Droplet) {
        self.drop = drop
        startSocket()
    }
     func startSocket() {
        drop?.socket("ws", handler: { (req, ws) in
            print("New WebSocket connected: \(ws)")
            self.socks.append(ws)
            // ping the socket to keep it open
            try background {
                while ws.state == .open {
                    try? ws.ping()
                    self.drop?.console.wait(seconds: 10) // every 10 seconds
                }
            }
        
            ws.onText = { ws, text in
                print("Text received: \(text)")
                for object in self.socks {
                    try? object.send(text)
                }
            }
            
            ws.onClose = { sock, code, reason, clean in
            
                let index = self.socks.index(where: {$0 === sock})
                self.socks.remove(at: index ?? 0)
                print("Closed.")
            }
        })
    }
}
