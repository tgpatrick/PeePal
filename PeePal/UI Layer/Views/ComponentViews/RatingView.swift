//
//  RatingView.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/7/24.
//

import SwiftUI

struct RatingView: View {
    let restroom: Restroom
    var small: Bool = false

    var body: some View {
        Text(getPercent())
            .font(small ? .caption : .footnote)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .padding(small ? 0 : 5)
            .frame(width: small ? 100 : 150)
            .background(
                Group {
                    if !small {
                        getColor().opacity(0.6)
                    }
                }
            )
            .foregroundStyle(small ? getColor() : .primary)
            .cornerRadius(10)
    }

    func getColor() -> Color {
        if restroom.upvote > restroom.downvote {
            return Color(.changingTable)
        } else if restroom.upvote < restroom.downvote {
            return .red
        } else {
            return .gray
        }
    }

    func getPercent() -> String {
        let total = restroom.upvote + restroom.downvote
        var percent: Double
        if total == 0 {
            return "Not Yet Rated"
        } else if restroom.upvote == restroom.downvote {
            return "Neutral Ratings"
        }
        percent = (Double(restroom.upvote) / Double(restroom.upvote + restroom.downvote)) * 100
        return String(Int(percent)) + "% Positive"
    }
}

#Preview {
    RatingView(restroom: exampleRestroom)
}

#Preview {
    RatingView(restroom: exampleRestroom, small: true)
}
