//
//  PhoneSessionManager.swift
//  TrailFollower
//
//  Created by Jonathan Ryan on 3/17/26.
//

import Foundation
import WatchConnectivity

class PhoneSessionManager: NSObject, WCSessionDelegate {
    
    static let shared = PhoneSessionManager()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendCoordinates(_ coordinates: [(lat: Double, lon: Double)]) {
        print("WCSession activated: \(WCSession.default.activationState.rawValue)")
        
        guard WCSession.default.activationState == .activated else {
            print("WCSession not activated yet")
            return
        }
        
        // Convert coordinates to a simple array of dictionaries
        // WatchConnectivity can only send basic types like strings, numbers, arrays
        let data = coordinates.map { ["lat": $0.lat, "lon": $0.lon] }
        
        WCSession.default.sendMessage(
            ["coordinates": data],
            replyHandler: nil
        ) { error in
            print("Send error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Required WCSessionDelegate methods
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error = error {
            print("WCSession activation error: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}

