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
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0.0
    
    
    var body: some View {
        Map (position: $cameraPosition){
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
        .mapStyle(.hybrid(elevation: .realistic))
        .overlay(alignment: .bottom) {
            VStack(spacing: 8) {
                if isDownloading {
                    ProgressView(value: downloadProgress) {
                        Text("Caching map tiles...")
                            .font(.caption)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                Button {
                    Task {
                        await cacheMapTiles()
                    }
                } label: {
                    Label(
                        isDownloading ? "Caching..." : "Download for Offline",
                        systemImage: "arrow.down.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isDownloading ? Color.gray : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                .disabled(isDownloading)
                .padding(.bottom)
            }
        }
    }
    private func cacheMapTiles() async {
        guard !coordinates.isEmpty else { return }
        
        isDownloading = true
        downloadProgress = 0.0
        
        // Calculate bounding box around the trail
        let lats = coordinates.map { $0.latitude }
        let lons = coordinates.map { $0.longitude }
        
        let minLat = lats.min()!
        let maxLat = lats.max()!
        let minLon = lons.min()!
        let maxLon = lons.max()!
        
        // Expand the bounding box generously outward
        let padding = 0.05 // roughly 3-4 miles of padding
        let expandedMinLat = minLat - padding
        let expandedMaxLat = maxLat + padding
        let expandedMinLon = minLon - padding
        let expandedMaxLon = maxLon + padding
        
        // Define zoom levels to cache
        // Higher number = more detail but more tiles to download
        let zoomSteps: [Double] = [0.08, 0.04, 0.02, 0.01, 0.005]
        let totalSteps = Double(zoomSteps.count * 4) // 4 positions per zoom level
        var completedSteps = 0.0
        
        for span in zoomSteps {
            // Sample several positions across the bounding box at this zoom level
            let positions = [
                CLLocationCoordinate2D(
                    latitude: (expandedMinLat + expandedMaxLat) / 2,
                    longitude: (expandedMinLon + expandedMaxLon) / 2
                ), // center
                CLLocationCoordinate2D(latitude: expandedMinLat, longitude: expandedMinLon), // SW
                CLLocationCoordinate2D(latitude: expandedMaxLat, longitude: expandedMaxLon), // NE
                CLLocationCoordinate2D(latitude: expandedMinLat, longitude: expandedMaxLon), // SE
            ]
            
            for position in positions {
                let region = MKCoordinateRegion(
                    center: position,
                    span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
                )
                cameraPosition = .region(region)
                
                // Wait for tiles to load at each position
                try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
                
                completedSteps += 1
                downloadProgress = completedSteps / totalSteps
            }
        }
        
        // Return to showing the full trail
        cameraPosition = .automatic
        isDownloading = false
        downloadProgress = 1.0
    }
}
