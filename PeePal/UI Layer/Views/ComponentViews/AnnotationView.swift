//
//  AnnotationView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/12/20.
//

import SwiftUI

struct RestroomAnnotation: View {
    let restroom: Restroom
    let gradient: LinearGradient

    init(restroom: Restroom) {
        self.restroom = restroom
        var gradientStart: Color = Color(.accent)
        var gradientEnd: Color = Color(.accentColorLight)
        if restroom.accessible {
            gradientStart = Color(.accessible)
        }
        if restroom.unisex {
            gradientEnd = Color(.unisex)
        }
        self.gradient = LinearGradient(
            gradient: .init(colors: [gradientStart, gradientEnd]),
            startPoint: .init(x: 0.5, y: 0.2),
            endPoint: .init(x: 0.5, y: 0.6)
        )
    }

    var body: some View {
        Image(.icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 15)
            .padding(7.5)
            .padding(.bottom, 3.25)
            .background(
                alignment: .bottom,
                content: {
                    Point(heightRadiusRatio: 1.5)
                        .foregroundStyle(
                            gradient.shadow(
                                .inner(color: .black.opacity(0.5), radius: 5)
                            )
                        )
                        .shadow(radius: 5)
                }
            )
    }
}

struct ClusterAnnotation: View {
    let cluster: RestroomCluster

    var body: some View {
        Text("\(cluster.size)")
            .padding(7.5)
            .foregroundStyle(.black)
            .background(
                Circle()
                    .foregroundStyle(
                        Color.accentColor.gradient.shadow(
                            .inner(color: .black.opacity(0.25), radius: 5)
                        )
                    )
                    .shadow(radius: 5)
            )
            .fontDesign(.rounded)
            .fontWeight(.bold)
    }
}

struct AnnotationView_Old: View {
    var restroom: Restroom
    @ObservedObject var sharedModel: SharedModel
    @ObservedObject var contentModel: ContentViewModel_Old
    var gradientStart: Color = Color(.accent)
    var gradientEnd: Color = Color(.accentColorLight)
    
    init(restroom: Restroom, viewModel: SharedModel, contentViewModel: ContentViewModel_Old) {
        self.restroom = restroom
        self.sharedModel = viewModel
        self.contentModel = contentViewModel
        if restroom.accessible {
            self.gradientStart = Color(.accessible)
        }
        if restroom.unisex {
            self.gradientEnd = Color(.unisex)
        }
    }
    
    var body: some View {
        ZStack {
            if contentModel.showDetail && contentModel.detailRestroom.id == restroom.id {
                ShadowPoint(gradientStart: gradientStart, gradientEnd: gradientEnd)
            }
            ZStack {
                Point(heightRadiusRatio: 1.5)
                    .fill(LinearGradient(
                        gradient: .init(colors: [gradientStart, gradientEnd]),
                        startPoint: .init(x: 0.5, y: 0.2),
                        endPoint: .init(x: 0.5, y: 0.6)
                    ))
                    .shadow(color: .black, radius: 2)
                Image(.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(CGSize(width: 0.5, height: 0.5))
                    .offset(x: 0, y: -3)
            }
            .frame(width: 45, height: 45, alignment: .center)
        }
    }
}

struct Point: Shape {
    let heightRadiusRatio: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = rect.height / (1 + heightRadiusRatio)
        let bottom = CGPoint(x: rect.width / 2, y: rect.height)
        path.move(to: bottom)
        path.addArc(center: CGPoint(x: bottom.x, y: radius), radius: radius, startAngle: .degrees(140), endAngle: .degrees(400), clockwise: false)
        path.addLine(to: bottom)
        return path
    }
}

struct ShadowPoint: View {
    var gradientStart: Color = .yellow
    var gradientEnd: Color = .accentColor
    
    var body: some View {
        ZStack {
            Circle()
                .rotation(Angle.degrees(25))
                .trim(from: 0.36, to: 1)
                .frame(width: 35, height: 35)
                .offset(y: -5)
                .shadow(color: gradientStart, radius: 5)
                .shadow(color: gradientStart, radius: 5)
                .shadow(color: gradientStart, radius: 5)
            Rectangle()
                .trim(from: 0.35, to: 0.65)
                .rotationEffect(Angle.degrees(45))
                .frame(width: 35, height: 35)
                .offset(y: -4)
                .shadow(color: gradientEnd, radius: 5)
                .shadow(color: gradientEnd, radius: 5)
                .shadow(color: gradientEnd, radius: 5)
                .shadow(color: gradientEnd, radius: 5)
        }
    }
}

struct AnnotationView_Previews: PreviewProvider {
    static var previewRestroom = exampleRestroom
    
    static var previews: some View {
        ContentView()
    }
}
