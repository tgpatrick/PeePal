//
//  AnnotationView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/12/20.
//

import SwiftUI

struct AnnotationView: View {
    var restroom: Restroom
    @ObservedObject var cvm: ContentViewModel
    var gradientStart: Color = Color("AccentColor")
    var gradientEnd: Color = Color("AccentColor.Light")
    
    init(restroom: Restroom, viewModel: SharedModel, contentViewModel: ContentViewModel) {
        self.restroom = restroom
        self.cvm = contentViewModel
        if restroom.accessible {
            self.gradientStart = Color("Accessible")
        }
        if restroom.unisex {
            self.gradientEnd = Color("Unisex")
        }
    }
    
    var body: some View {
        ZStack {
            if cvm.showDetail && cvm.detailRestroom.id == restroom.id  {
                ShadowPoint(gradientStart: gradientStart, gradientEnd: gradientEnd)
            }
            Point(heightRadiusRatio: 1.5)
                .fill(LinearGradient(
                    gradient: .init(colors: [gradientStart, gradientEnd]),
                    startPoint: .init(x: 0.5, y: 0.2),
                    endPoint: .init(x: 0.5, y: 0.6)
                ))
            Point(heightRadiusRatio: 1.5)
                .stroke()
            Image("Icon")
                .resizable()
                .scaleEffect(CGSize(width: 0.3, height: 0.5))
                .offset(x: 0.25, y: -4)
        }
        .frame(width: 45, height: 45, alignment: .center)
        .onTapGesture(perform: {
            self.cvm.showDetail(restroom: restroom)
        })
        .adaptiveShadow(radius: 10)
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

var previewRestroom = exampleRestroom

struct AnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ContentView(sharedModel: searchModel)
                .onAppear(perform: {
                    searchModel.showTutorial = false
                })
            AnnotationView(restroom: previewRestroom, viewModel: searchModel, contentViewModel: ContentViewModel())
                .onAppear(perform: {
                    previewRestroom.unisex = false
                    previewRestroom.accessible = false
                    previewRestroom.changing_table = false
                })
        }
        .colorScheme(.dark)
    }
}
