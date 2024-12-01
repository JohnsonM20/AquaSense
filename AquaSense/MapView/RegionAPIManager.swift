
import SwiftUI
import MapKit

// MARK: - Data Models

import SwiftUI
import MapKit

// MARK: - Data Models

struct APIResponse: Codable {
    let total_count: Int
    let results: [ResultItem]
}

struct ResultItem: Codable {
    let geo_point_2d: GeoPoint2D
    let geo_shape: GeoShape
    let year: String
    let reg_code: [String]
    let reg_current_code: [String]
    let reg_name: [String]
    let reg_name_upper: String
    let reg_name_lower: String
    let reg_area_code: String
    let reg_type: String
    let reg_is_ctu: String
    let reg_siren_code: String?
}

struct GeoPoint2D: Codable {
    let lon: Double
    let lat: Double
}

struct GeoShape: Codable {
    let type: String
    let geometry: Geometry
    let properties: [String: String]
}

struct Geometry: Codable {
    let coordinates: Coordinates
    let type: String
}

enum Coordinates: Codable {
    case polygon([[[Double]]])
    case multiPolygon([[[[Double]]]])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let multiPolygon = try? container.decode([[[[Double]]]].self) {
            self = .multiPolygon(multiPolygon)
        } else if let polygon = try? container.decode([[[Double]]].self) {
            self = .polygon(polygon)
        } else {
            throw DecodingError.typeMismatch(
                Coordinates.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected Polygon or MultiPolygon"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .polygon(let polygon):
            try container.encode(polygon)
        case .multiPolygon(let multiPolygon):
            try container.encode(multiPolygon)
        }
    }
}

// MARK: - ViewModel

class MapPolygonViewModel: ObservableObject {
    @Published var mapPolygons: [PolygonData] = []

    func fetchPolygons() {
        guard let url = URL(string: "https://data.opendatasoft.com/api/explore/v2.1/catalog/datasets/regions-et-collectivites-doutre-mer-france@toursmetropole/records?limit=20") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                // For debugging: print the raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }

                do {
                    let decoder = JSONDecoder()
                    // Remove keyDecodingStrategy since we're matching the keys exactly
                    let apiResponse = try decoder.decode(APIResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.processResponse(apiResponse)
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else if let error = error {
                print("HTTP request failed: \(error)")
            }
        }
        task.resume()
    }

    private func processResponse(_ apiResponse: APIResponse) {
        var polygons: [PolygonData] = []
        
        for resultItem in apiResponse.results {
            let geometry = resultItem.geo_shape.geometry
            let regionName = resultItem.reg_name.first ?? "Unknown" // Extract the region name
            
            switch geometry.coordinates {
            case .polygon(let coordinates):
                for linearRing in coordinates {
                    let coords = linearRing.map { position -> CLLocationCoordinate2D in
                        let lon = position[0]
                        let lat = position[1]
                        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                    let polygonData = PolygonData(coordinates: coords, regionName: regionName)
                    polygons.append(polygonData)
                }
            case .multiPolygon(let multiCoordinates):
                for polygon in multiCoordinates {
                    for linearRing in polygon {
                        let coords = linearRing.map { position -> CLLocationCoordinate2D in
                            let lon = position[0]
                            let lat = position[1]
                            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        }
                        let polygonData = PolygonData(coordinates: coords, regionName: regionName)
                        polygons.append(polygonData)
                    }
                }
            }
        }
        self.mapPolygons = polygons
    }
}

// MARK: - Polygon Data

struct PolygonData: Identifiable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
    let regionName: String
}
