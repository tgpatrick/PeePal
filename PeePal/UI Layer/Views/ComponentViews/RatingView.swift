//
//  RatingView.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/7/24.
//

import SwiftUI

struct RatingView: View {
    let restroom: Restroom
    var width: CGFloat = 150
    var font: Font = .footnote

    var body: some View {
        Text(getPercent())
            .font(font)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .padding(5)
            .frame(width: width)
            .background(getColor().opacity(0.6))
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
