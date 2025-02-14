//
//  EventItemComponentHorizontal.swift
//  GameSocial
//
//  Created by Adam Gumm on 2/3/25.
//


import SwiftUI

struct EventItemComponentHorizontal: View {
    @Environment(\.colorScheme) var colorScheme

    enum Size {
        case small, large
    }
    
    // Inputs
    let size: Size
    let day: String            // e.g. "23"
    let month: String          // e.g. "AUG"
    let dayOfTheWeek: String   // Friday
    let eventName: String      // e.g. "Beach Party"
    let eventTime: String      // e.g. "8:30 pm - 11:00 pm"
    let distance: Double       // e.g. 1 => "1 m"
    let imageURL: URL?         // Remote image url
    let venueName: String

    var body: some View {
        HStack(spacing: 0) {
            // LEFT SIDE: Image with date badge in top-right
            ZStack(alignment: .topTrailing) {
                // Image
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: imageWidth, height: imageHeight)
                            .background(Color.gray.opacity(0.2))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageWidth, height: imageHeight)
                            .clipped()
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            .frame(width: imageWidth, height: imageHeight)
                            .background(Color.gray.opacity(0.2))
                    @unknown default:
                        EmptyView()
                    }
                }
                .background(Color.gray.opacity(0.1))
                
                // Date badge (top-right)
                VStack(spacing: 0) {
                    Text(day)
                        .font(size == .small ? .body : .title)
                        .bold()
                        .foregroundColor(.black)
                    Text(month.uppercased())
                        .font(size == .small ? .caption : .headline)
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(8)
                .padding([.top, .trailing], 6)
            }
            
            // RIGHT SIDE: Event details
            VStack(alignment: .leading, spacing: 6) {
                // Title + distance
                Text(eventName)
                    .font(size == .small ? .headline : .title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                // Day/time
                Text("\(dayOfTheWeek) @ \(eventTime)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(month) \(day)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                
                Text("\(venueName) (\(distanceString()))")
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.clear)
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helpers
    private var imageWidth: CGFloat {
        size == .small ? 100 : 140
    }
    
    private var imageHeight: CGFloat {
        size == .small ? 110 : 120
    }
    
    private func distanceString() -> String {
        let truncated = Int(floor(distance))
        return "\(truncated) m"
    }
}

// MARK: - Preview
struct EventItemComponentHorizontal_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventItemComponentHorizontal(
                size: .small,
                day: "23",
                month: "Aug",
                dayOfTheWeek: "Friday",
                eventName: "Beach Party",
                eventTime: "8:30 pm - 11:00 pm",
                distance: 10,
                imageURL: URL(string: "https://picsum.photos/400/300"),
                venueName: "Adam's Bar"
            )
            .previewLayout(.sizeThatFits)
            .padding()
            
            EventItemComponentHorizontal(
                size: .large,
                day: "23",
                month: "Aug",
                dayOfTheWeek: "Friday",
                eventName: "Adam's Pub",
                eventTime: "8:30 pm - 11:00 pm",
                distance: 1,
                imageURL: URL(string: "https://picsum.photos/600/400"),
                venueName: "Rory's Playroom"
            )
            .previewLayout(.sizeThatFits)
            .padding()
        }
    }
}
