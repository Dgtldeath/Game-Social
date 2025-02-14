//
//  EventViewModel.swift
//  GameSocial
//
//  Created by Adam Gumm on 1/31/25.
//


import SwiftUI
import Combine
import CoreLocation
import UserNotifications

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
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
        fetchEvents()
    }

    func fetchEvents() {
        guard let url = URL(string: eventsAPIURLString) else {
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Event].self, decoder: JSONDecoder())
            // .replaceError(with: []) // comment this out
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("DEBUG: Decoding error: \(error)")
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] events in
                    self?.events = events
                    print("DEBUG: Decoded events = \(events)")
                    self?.calculateDistances()
                }
            )
            .store(in: &cancellables)
    }

//    private func sortEventsByDistance() {
//        guard let userLocation = userLocation else { return }
//
//        events.sort { (eventA, eventB) -> Bool in
//            guard
//                let latA = eventA.latitude,
//                let lonA = eventA.longitude,
//                let latB = eventB.latitude,
//                let lonB = eventB.longitude
//            else {
//                // If any event lacks valid coordinates, choose how to handle sorting
//                return false
//            }
//            let locA = CLLocation(latitude: latA, longitude: lonA)
//            let locB = CLLocation(latitude: latB, longitude: lonB)
//            return userLocation.distance(from: locA) < userLocation.distance(from: locB)
//        }
//    }

    private func calculateDistances() {
        guard let userLocation = userLocation else { return }
        
        events = events.map { event in
            guard
                let lat = event.venue?.latitude,
                let lon = event.venue?.longitude
            else {
                // Return event with distanceMiles = nil
                var copy = event
                copy.distanceMiles = nil
                return copy
            }
            
            let venueLocation = CLLocation(latitude: lat, longitude: lon)
            let distanceMeters = userLocation.distance(from: venueLocation)
            let distanceMiles = distanceMeters / 1609.34
            
            var copy = event
            copy.distanceMiles = distanceMiles
            return copy
        }
        
        // Optionally sort by distance
        // events.sort { ($0.distanceMiles ?? Double.greatestFiniteMagnitude) < ($1.distanceMiles ?? Double.greatestFiniteMagnitude) }
    }

    func scheduleReminder(for event: Event) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder for \(event.name)"
        content.body = "Don't forget to plan for today's event!"
        content.sound = .default

        // Parse the event's start date.
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"  // e.g., "2025-01-15"
        
        guard let eventDay = dateFormatter.date(from: event.startDate) else {
            print("Failed to parse event date for event: \(event.name)")
            return
        }
        
        // Create a reminder date set to 8:00 AM on the same day as the event.
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: eventDay)
        components.hour = 8
        components.minute = 0
        components.second = 0
        
        guard let reminderDate = calendar.date(from: components) else {
            print("Failed to create reminder date for event: \(event.name)")
            return
        }
        
        // Ensure the reminder date is in the future.
        let now = Date()
        if reminderDate < now {
            print("Reminder time is in the past for event: \(event.name)")
            return
        }
        
        // Create a trigger using the reminder date components.
        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "reminder_\(event.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for event id: \(event.id) at \(reminderDate)")
            }
        }
    }
}
