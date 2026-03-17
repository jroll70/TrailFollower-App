//
//  PathMapView.swift
//  TrailFollower
//
//  Created by Jonathan Ryan on 3/17/26.
//

import SwiftUI
import MapKit

struct PathMapView: View {
    let coordinates: [CLLocationCoordinate2D]
    @StateObject private var locationManager = LocationManager()
    
    
    var body: some View {
        Map {
            MapPolyline(coordinates: coordinates)
                .stroke(.blue, lineWidth: 3)
            
            if let location = locationManager.userLocation {
                Annotation("You", coordinate: location) {
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.3))
                            .frame(width: 32, height: 32)
                        Circle()
                            .fill(.blue)
                            .frame(width: 14, height: 14)
                        Circle()
                            .strokeBorder(.white, lineWidth: 2)
                            .frame(width: 14, height: 14)
                    }
                }
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
}
