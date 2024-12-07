import Foundation

// MARK: - Root
struct PerenualResponse: Codable {
    let data: [Plant]
    let to: Int
    let perPage: Int
    let currentPage: Int
    let from: Int
    let lastPage: Int
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case data
        case to
        case perPage = "per_page"
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case total
    }
}

// MARK: - Plant
struct Plant: Codable {
    let id: Int
    let commonName: String?
    let scientificName: [String]
    let otherName: [String]?
    let cycle: String
    let watering: String
    let sunlight: [String]
    let defaultImage: PlantImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case otherName = "other_name"
        case cycle
        case watering
        case sunlight
        case defaultImage = "default_image"
    }
}

// MARK: - PlantImage
struct PlantImage: Codable {
    let imageId: Int
    let license: Int
    let licenseName: String
    let licenseURL: String
    let originalURL: String
    let regularURL: String
    let mediumURL: String
    let smallURL: String
    let thumbnail: String
    
    enum CodingKeys: String, CodingKey {
        case imageId = "image_id"
        case license
        case licenseName = "license_name"
        case licenseURL = "license_url"
        case originalURL = "original_url"
        case regularURL = "regular_url"
        case mediumURL = "medium_url"
        case smallURL = "small_url"
        case thumbnail
    }
}
