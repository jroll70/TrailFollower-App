//
//  ContentView.swift
//  TrailFollower
//
//  Created by Jonathan Ryan on 3/17/26.
//

import SwiftUI
import CoreLocation
internal import UniformTypeIdentifiers

struct ContentView: View {

    // @State vars trigger a UI refresh when they change
    @State private var isImporting = false
    @State private var coordinates: [CLLocationCoordinate2D] = []
    @State private var errorMessage: String?
    @State private var showMap = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // Show coordinate count or a prompt
                if coordinates.isEmpty {
                    ContentUnavailableView(
                        "No Path Loaded",
                        systemImage: "map",
                        description: Text("Import a KML file to get started")
                    )
                } else {
                    // List the first few coordinates as a sanity check
                    List {
                        Section("Loaded \(coordinates.count) points") {
                            ForEach(Array(coordinates.prefix(10).enumerated()), id: \.offset) { index, coord in
                                VStack(alignment: .leading) {
                                    Text("Point \(index + 1)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("lat: \(coord.latitude, specifier: "%.5f")  lon: \(coord.longitude, specifier: "%.5f")")
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                        }
                    }
                }

                // Error display
                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                }

                // Import button
                Button {
                    isImporting = true
                } label: {
                    Label("Import KML File", systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
                
                if !coordinates.isEmpty {
                    Button {
                        showMap = true
                    } label: {
                        Label("Show on Map", systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                }
                
                Button {
                    if let url = Bundle.main.url(forResource: "Daughenbaugh Open Space to gravity Brewing", withExtension: "kml") {
                        let parser = KMLParser()
                        let parsed = parser.parse(url: url)
                        if parsed.isEmpty {
                            errorMessage = "No coordinates found"
                        } else {
                            coordinates = parsed
                            errorMessage = nil
                        }
                    } else {
                        errorMessage = "Test file not found"
                    }
                } label: {
                    Label("Load Test KML", systemImage: "doc.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }

            }
            .navigationTitle("Trail Follower")
            // File picker sheet
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.xml],  // KML files are XML under the hood
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .sheet(isPresented: $showMap) {
                PathMapView(coordinates: coordinates)
            }
        }
    }

    // Handles the result from the file picker
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            // iOS sandboxing requires this to access files outside the app
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing { url.stopAccessingSecurityScopedResource() }
            }

            let parser = KMLParser()
            let parsed = parser.parse(url: url)

            if parsed.isEmpty {
                errorMessage = "No coordinates found in file"
            } else {
                coordinates = parsed
                errorMessage = nil
            }

        case .failure(let error):
            errorMessage = "Import failed: \(error.localizedDescription)"
        }
    }
}
