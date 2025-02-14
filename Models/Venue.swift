//
//  Venue.swift
//  GameSocial
//
//  Created by Adam Gumm on 2/2/25.
//


import Foundation

// MARK: - Venue
struct Venue: Identifiable, Decodable {
    let id: Int
    let name: String
    let address: String?
    let website: String?
    let cityID: Int?
    let createdAt: String?
    let updatedAt: String?
    let deletedAt: String?
    let latitude: Double?
    let longitude: Double?
    let logo_url: String
    
    
    var distanceMiles: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case website
        case cityID    = "city_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case latitude, longitude
        case logo_url = "logo_url"
    }
}
