//
//  WatchMapview.swift
//  TrailFollower Watch App Watch App
//
//  Created by Jonathan Ryan on 3/17/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct WatchMapView: View {
    let coordinates: [CLLocationCoordinate2D]
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition) {
            MapPolyline(coordinates: coordinates)
                .stroke(.blue, lineWidth: 3)
            
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic))
        .onAppear {
            zoomToTrail()
        }
    }
    
    private func zoomToTrail() {
        guard !coordinates.isEmpty else { return }
        
        let lats = coordinates.map { $0.latitude }
        let lons = coordinates.map { $0.longitude }
        
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
        
        // Tighter zoom than the iPhone version
        let span = MKCoordinateSpan(
            latitudeDelta: (lats.max()! - lats.min()!) * 1.3,
            longitudeDelta: (lons.max()! - lons.min()!) * 1.3
        )
        
        cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }
}
