//
//  BookmarkedEventsView.swift
//  GameSocial
//
//  Created by Adam Gumm on 2/1/25.
//


import SwiftUI
import SwiftData

struct BookmarkedEventsView: View {
    @Query var savedEvents: [BookmarkedEvent]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            ForEach(savedEvents) { item in
                Text(item.name)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Bookmarked Events")
    }
    
    private func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            let event = savedEvents[index]
            modelContext.delete(event)
        }
        try? modelContext.save()
    }
}
