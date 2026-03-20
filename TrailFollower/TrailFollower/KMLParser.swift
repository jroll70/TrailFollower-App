//
//  KMLParser.swift
//  TrailFollower
//
//  Created by Jonathan Ryan on 3/17/26.
//

import Foundation
import CoreLocation

class KMLParser: NSObject, XMLParserDelegate {
    private(set) var coordinates: [CLLocationCoordinate2D] = []
    private var currentElement = ""
    private var currentText = ""
    private var currentLat: Double?
    private var currentLon: Double?
    
    func parse(url: URL) -> [CLLocationCoordinate2D] {
        coordinates = []
        
        guard let parser = XMLParser(contentsOf: url) else {
            print("Failed to load KML file")
            return []
        }
        
        parser.delegate = self
        parser.parse()
        return coordinates
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes: [String: String] = [:]) {
        currentElement = elementName
        currentText = ""
        
        // Handle GPX trkpt elements - coordinates are in attributes
        if elementName == "trkpt" {
            if let latStr = attributes["lat"],
               let lonStr = attributes["lon"],
               let lat = Double(latStr),
               let lon = Double(lonStr) {
                coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "coordinates" {
            parseCoordinateBlock(currentText)
        }
    }
    
    private func parseCoordinateBlock(_ text: String) {
        let lines = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        for line in lines {
            let parts = line.components(separatedBy: ",")
            if parts.count >= 2,
               let lon = Double(parts[0].trimmingCharacters(in: .whitespaces)),
               let lat = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
                coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        }
    }
}
