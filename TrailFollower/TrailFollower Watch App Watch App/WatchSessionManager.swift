//
//  WatchSessionManager.swift
//  TrailFollower Watch App Watch App
//
//  Created by Jonathan Ryan on 3/17/26.
//

import Foundation
import WatchConnectivity
import CoreLocation

class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    
    var coordinates: [CLLocationCoordinate2D] = []
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
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
    
    func session(_ session: WCSession,
                 didReceiveUserInfo userInfo: [String: Any]) {
        guard let rawCoords = userInfo["coordinates"] as? [[String: Double]] else {
            return
        }
        
        let parsed = rawCoords.compactMap { dict -> CLLocationCoordinate2D? in
            guard let lat = dict["lat"], let lon = dict["lon"] else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        DispatchQueue.main.async {
            self.coordinates = parsed
            NotificationCenter.default.post(name: .coordinatesUpdated, object: nil)
        }
    }
}

// This must be outside the class
extension Notification.Name {
    static let coordinatesUpdated = Notification.Name("coordinatesUpdated")
}
