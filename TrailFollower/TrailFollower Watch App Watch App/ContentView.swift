//
//  ContentView.swift
//  TrailFollower Watch App Watch App
//
//  Created by Jonathan Ryan on 3/17/26.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var coordinates: [CLLocationCoordinate2D] = []
    
    var body: some View {
        Group {
            if coordinates.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.title2)
                    Text("Send trail from iPhone")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.secondary)
            } else {
                WatchMapView(coordinates: coordinates)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .coordinatesUpdated)) { _ in
            coordinates = WatchSessionManager.shared.coordinates
        }
    }
}
