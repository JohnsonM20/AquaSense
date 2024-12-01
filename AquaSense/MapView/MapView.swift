//
//  SecondaryView.swift
//  AquaSense
//
//  Created by Matthew Johnson on 11/29/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    ))
    
    @StateObject var viewModel = MapPolygonViewModel()
    
    @State var regionColors: [String: Color] = [:] // Mapping of region names to colors
    
    // Define a palette of colors
    let colorPalette: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow, .gray]
    
    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(viewModel.mapPolygons) { polygonData in
                let color = regionColors[polygonData.regionName] ?? Color.blue
                MapPolygon(coordinates: polygonData.coordinates)
                    .foregroundStyle(color.opacity(0.7))
            }
        }
        .onAppear {
            viewModel.fetchPolygons()
        }
        .onReceive(viewModel.$mapPolygons) { polygons in
            if let region = computeRegion(for: polygons) {
                cameraPosition = .region(region)
            }
            generateRegionColors(polygons: polygons)
        }
    }
    
    func generateRegionColors(polygons: [PolygonData]) {
        var newRegionColors: [String: Color] = [:]
        var colorIndex = 0
        
        let uniqueRegions = Set(polygons.map { $0.regionName })
        
        for regionName in uniqueRegions {
            let color = colorPalette[colorIndex % colorPalette.count]
            newRegionColors[regionName] = color
            colorIndex += 1
        }
        regionColors = newRegionColors
    }
    
    func computeRegion(for polygons: [PolygonData]) -> MKCoordinateRegion? {
        guard !polygons.isEmpty else { return nil }

        var minLat = 90.0
        var maxLat = -90.0
        var minLon = 180.0
        var maxLon = -180.0

        for polygon in polygons {
            for coord in polygon.coordinates {
                minLat = min(minLat, coord.latitude)
                maxLat = max(maxLat, coord.latitude)
                minLon = min(minLon, coord.longitude)
                maxLon = max(maxLon, coord.longitude)
            }
        }

        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2

        let spanLat = (maxLat - minLat) * 1.2 // Add some padding
        let spanLon = (maxLon - minLon) * 1.2

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
        )
    }

}

#Preview {
    MapView()
}
