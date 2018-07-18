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
                self.socks.remove(at: index!)
                print("Closed.")
            }
        })
    }
    
    func parseJSON(jsonString:String) -> Form? {
        var object:Form?
        do {
            object = try JSONDecoder().decode(Form.self, from: jsonString.data(using: .utf8)!)
        } catch {
            print(error)
        }
        return object
    }
}

struct Form: Codable {
    let lat: String
    let long: String
    let id: String
    var sock: WebSocket?
    let jsonEncoder = JSONEncoder()
    private enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case long = "long"
        case id = "id"
    }
    func encode() -> Data {
        let jsonData = try! jsonEncoder.encode(self)
        return jsonData
    }
}

protocol Stringfy {}

extension Stringfy {
    func toString(data:Data) -> String {
        return String(data:data, encoding: .utf8)!
    }
}
extension Data:Stringfy {}



