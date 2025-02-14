//
//  GameSocial
//
//  Created by Adam Gumm on 1/31/25.
//


import SwiftUI
import UserNotifications
import SwiftData

struct UpcomingEventView: View {
    @Environment(\.colorScheme) var colorScheme

    @StateObject var viewModel = EventViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var searchText: String = ""
    
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        NavigationView {
            List(filteredEvents) { event in
                NavigationLink(destination: EventDetailView(event: event)) {
                    
                    // 1. Parse the date/time
                    let dateString  = event.readableDate ?? event.startDate
                    let timeString  = event.readableTime ?? event.startTime
                    let (day, month, dayOfWeek) = parseDayMonth(dateString)
                    
                    // 3. Venue Name
                    let venueName   = event.venue?.name ?? "No Venue"
                    
                    // 4. Construct the horizontal item
                    EventItemComponentHorizontal(
                        size: .small,
                        day: day,
                        month: month,
                        dayOfTheWeek: dayOfWeek,
                        eventName: event.name,
                        eventTime: timeString,
                        distance: event.distanceMiles ?? 0,
                        imageURL: URL(string: event.imageURL), 
                        venueName: venueName
                    )
                }
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    // BOOKMARK
                    Button {
                        Task {
                            await bookmarkEvent(event)
                        }
                    } label: {
                        Label("Bookmark", systemImage: "bookmark")
                    }
                    .tint(.green)
                    
                    // Reminder button
                    Button {
                        requestNotificationPermission {
                            viewModel.scheduleReminder(for: event)
                            toastMessage = "Event reminder set!"
                            showToast = true
                            // Hide the toast after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showToast = false
                            }
                        }
                    } label: {
                        Label("Remind Me", systemImage: "clock")
                    }
                    .tint(.blue)
                }
            }
            .searchable(text: $searchText, prompt: "Search events...")
            .refreshable {
                viewModel.fetchEvents()
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Upcoming Events")
        }
        .tint(Color.white)
        .toast(isPresented: $showToast, message: toastMessage)
    }
    
    private var filteredEvents: [Event] {
        // If the user hasn’t typed anything, return all events
        guard !searchText.isEmpty else {
            return viewModel.events
        }
        
        // Otherwise, filter by any matching property
        let lowerSearch = searchText.lowercased()
        return viewModel.events.filter { event in
            // Check if event name matches
            if event.name.lowercased().contains(lowerSearch) { return true }
            
            // Check details
            if let details = event.details,
               details.lowercased().contains(lowerSearch) {
                return true
            }
            
            // Check venue name
            if let venueName = event.venue?.name.lowercased(),
               venueName.contains(lowerSearch) {
                return true
            }
            
            return false
        }
    }

    
    // This is the function called in the swipe action
    func bookmarkEvent(_ event: Event) async {
        // Create a new bookmarked event
        let bookmarked = BookmarkedEvent(
            eventID: event.id,
            name: event.name,
            date: event.readableDate ?? event.startDate,
            time: event.readableTime ?? event.startTime
        )
        
        do {
            // Insert into the context and save
            modelContext.insert(bookmarked)
            try modelContext.save()
            
            print("Bookmarked event \(bookmarked.eventID) successfully!")
            
            toastMessage = "Bookmarked event successfully!"
            showToast = true
            
            // Hide the toast after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
        } catch {
            print("Error bookmarking event: \(error)")
        }
    }
    
    // Helper function: request notification authorization
    func requestNotificationPermission(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error)")
                    return
                }
                if granted {
                    completion()
                } else {
                    print("User did not grant permission for notifications.")
                }
            }
    }
}

#Preview {
    UpcomingEventView()
        //.modelContainer(for: Item.self, inMemory: true)
}
