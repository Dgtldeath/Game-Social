//
//  VenueViewModel.swift
//  GameSocial
//
//  Created by Adam Gumm on 2/2/25.
//


import SwiftUI
import Combine
import CoreLocation

class VenueViewModel: ObservableObject {
    @Published var venues: [Venue] = []
    @Published var userLocation: CLLocation? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = LocationManager()
    
    init() {
        // Whenever location updates, store it in userLocation and sort events
        locationManager.$userLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                self?.userLocation = location
                //self?.sortEventsByDistance()
            }
            .store(in: &cancellables)

        // Fetch from remote on init
        fetchVenues()
    }

    func fetchVenues() {
        guard let url = URL(string: venueAPIURLString) else { return }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Venue].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching venues: \(error)")
                }
            }, receiveValue: { [weak self] venues in
                self?.venues = venues
                self?.calculateDistances()
            })
            .store(in: &cancellables)
    }
    
    private func calculateDistances() {
        guard let userLocation = userLocation else { return }
        
        venues = venues.map { _venue in
            guard
                let lat = _venue.latitude,
                let lon = _venue.longitude
            else {
                // Return event with distanceMiles = nil
                var copy = _venue
                copy.distanceMiles = nil
                return copy
            }
            
            let venueLocation = CLLocation(latitude: lat, longitude: lon)
            let distanceMeters = userLocation.distance(from: venueLocation)
            let distanceMiles = distanceMeters / 1609.34
            
            print("calc: \(distanceMiles)")
            var copy = _venue
            copy.distanceMiles = distanceMiles
            return copy
        }
        
        // Optionally sort by distance
        // events.sort { ($0.distanceMiles ?? Double.greatestFiniteMagnitude) < ($1.distanceMiles ?? Double.greatestFiniteMagnitude) }
    }
}

