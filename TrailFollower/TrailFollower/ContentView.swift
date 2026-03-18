//
//  ContentView.swift
//  TrailFollower
//
//  Created by Jonathan Ryan on 3/17/26.
//
import SwiftUI
import CoreLocation
import UniformTypeIdentifiers

extension UTType {
    static var kml: UTType {
        UTType(filenameExtension: "kml") ?? .xml
    }
}

struct ContentView: View {

    @State private var isImporting = false
    @State private var coordinates: [CLLocationCoordinate2D] = []
    @State private var errorMessage: String?
    @State private var importedFileName: String = ""
    private let sessionManager = PhoneSessionManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                if coordinates.isEmpty {
                    ContentUnavailableView(
                        "No Path Loaded",
                        systemImage: "map",
                        description: Text("Import a KML file to get started")
                    )
                } else {
                    ContentUnavailableView(
                        importedFileName,
                        systemImage: "checkmark.circle.fill",
                        description: Text("Trail loaded successfully")
                    )
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                }

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
                
#if DEBUG
Button {
    if let url = Bundle.main.url(forResource: "Daughenbaugh Open Space to gravity Brewing", withExtension: "kml") {
        let parser = KMLParser()
        let parsed = parser.parse(url: url)
        if parsed.isEmpty {
            errorMessage = "No coordinates found"
        } else {
            coordinates = parsed
            errorMessage = nil
            importedFileName = "Test KML"
        }
    } else {
        errorMessage = "Test file not found"
    }
} label: {
    Label("Load Test KML", systemImage: "doc.fill")
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.orange)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
}
#endif

                if !coordinates.isEmpty {
                    NavigationLink(destination: PathMapView(coordinates: coordinates)) {
                        Label("Show on Map", systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                    Button {
                            let sendable = coordinates.map { (lat: $0.latitude, lon: $0.longitude) }
                            sessionManager.sendCoordinates(sendable)
                        } label: {
                            Label("Send to Watch", systemImage: "applewatch")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.indigo)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                        }
                }

            }
            .navigationTitle("Trail Follower")
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.xml, .kml],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

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
                importedFileName = url.deletingPathExtension().lastPathComponent
            }

        case .failure(let error):
            errorMessage = "Import failed: \(error.localizedDescription)"
        }
    }
}
