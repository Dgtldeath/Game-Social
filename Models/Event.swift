//
//  Event.swift
//  GameSocial
//
//  Created by Adam Gumm on 1/31/25.
//


import Foundation

// MARK: - Event
struct Event: Identifiable, Decodable {
    let id: Int
    let name: String
    let details: String?
    let startDate: String
    let startTime: String
    let readableDate: String?
    let readableTime: String?
    let venueID: Int?
    let categoryID: Int?
    let createdAt: String?
    let updatedAt: String?
    let deletedAt: String?
    let venue: Venue?
    let category: EventCategory?
    let imageURL: String
    
    var distanceMiles: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case details
        case startDate  = "start_date"
        case startTime  = "start_time"
        case readableDate = "readable_date"
        case readableTime = "readable_time" 
        case venueID    = "venue_id"
        case categoryID = "category_id"
        case createdAt  = "created_at"
        case updatedAt  = "updated_at"
        case deletedAt  = "deleted_at"
        case imageURL = "imageURL"
        case venue
        case category
    }
}



// MARK: - EventCategory
struct EventCategory: Decodable {
    let id: Int
    let name: String
    let createdAt: String?
    let updatedAt: String?
    let deletedAt: String?
    let image_url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case image_url = ""
    }
}
