//
//  AnnotationView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/12/20.
//

import SwiftUI

struct RestroomAnnotation: View {
    @Binding var selection: RestroomCluster?
    let restroom: Restroom

    @State private var isShowing = false

    private var gradientStart: Color = Color(.accent)
    private var gradientEnd: Color = Color(.accentColorLight)
    private var gradient: LinearGradient {
        LinearGradient(
            gradient: .init(colors: [gradientStart, gradientEnd]),
            startPoint: .init(x: 0.5, y: 0.2),
            endPoint: .init(x: 0.5, y: 0.6)
        )
    }
    
    private var morphProgress: CGFloat { isSelected ? 0 : 1}
    private var iconSize: CGFloat { isSelected ? 20 : 17.5 }
    private var iconPadding: CGFloat { iconSize * 0.4 }
    private var iconBottomPadding: CGFloat { iconPadding / 2 }

    private var isSelected: Bool {
        guard selection?.isSingle ?? false,
              let selectedRestroom = selection?.restrooms.first else {
            return false
        }
        return selectedRestroom == restroom
    }

    init(selection: Binding<RestroomCluster?>, restroom: Restroom) {
        self._selection = selection
        self.restroom = restroom
        if restroom.accessible {
            self.gradientStart = Color(.accessible)
        }
        if restroom.unisex {
            self.gradientEnd = Color(.unisex)
        }
    }

    var body: some View {
        VStack {
            Spacer()
            if isShowing && !isSelected {
                Image(.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: iconSize)
                    .padding(iconPadding)
                    .background(
                        Circle()
                            .foregroundStyle(
                                gradient.shadow(
                                    .inner(color: .black.opacity(0.25), radius: 5)
                                )
                            )
                            .shadow(radius: 5)
                    )
                    .zIndex(1)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.1, anchor: .center),
                            removal: .identity))
            } else if isShowing {
                Image(.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: iconSize)
                    .padding(iconPadding)
                    .padding(.bottom, iconBottomPadding)
                    .background(
                        alignment: .bottom,
                        content: {
                            Point(heightRadiusRatio: 1.5)
                                .foregroundStyle(
                                    gradient.shadow(
                                        .inner(color: .black.opacity(0.25), radius: 5)
                                    )
                                )
                                .shadow(radius: 5)
                                .background {
                                    ShadowPoint(
                                        gradientStart: gradientStart,
                                        gradientEnd: gradientEnd,
                                        size: iconSize * 1.4)
                                }
                        }
                    )
                    .zIndex(2)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.1, anchor: .bottom),
                            removal: .scale(scale: 0.1, anchor: .bottom)
                                .combined(with: .opacity)))
            }
        }
        .frame(width: 44, height: 50)
        .fixedSize()
        .animation(
            .interactiveSpring(extraBounce: 0.5),
            value: selection)
        .onAppear {
            withAnimation(.interactiveSpring(extraBounce: 0.5)) {
                isShowing = true
            }
        }

    }
}

struct ClusterAnnotation: View {
    @Binding var selection: RestroomCluster?
    let cluster: RestroomCluster

    @State private var isShowing = false

    private var isSelected: Bool {
        guard let selection else { return false }
        return selection == cluster
    }

    var body: some View {
        Group {
            if isShowing {
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
                            .shadow(
                                color: Color.accentColor,
                                radius: isSelected ? 10 : 0)
                    )
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                    .scaleEffect(isSelected ? 1.5 : 1)
                    .animation(
                        .interactiveSpring(extraBounce: 0.5),
                        value: selection)
                    .transition(.scale(scale: 0.1))
            }
        }
        .onAppear {
            withAnimation(.interactiveSpring(extraBounce: 0.5)) {
                isShowing = true
            }
        }
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
        path.addArc(
            center: CGPoint(x: bottom.x, y: radius),
            radius: radius,
            startAngle: .degrees(140),
            endAngle: .degrees(400),
            clockwise: false)
        path.addLine(to: bottom)
        return path
    }
}

struct ShadowPoint: View {
    var gradientStart: Color = .yellow
    var gradientEnd: Color = .accentColor
    var size: CGFloat = 35

    var body: some View {
        ZStack {
            Circle()
                .rotation(Angle.degrees(25))
                .trim(from: 0.36, to: 1)
                .frame(width: size, height: size)
                .offset(y: -5)
                .shadow(color: gradientStart, radius: 10)
                .shadow(color: gradientStart, radius: 10)
            Rectangle()
                .trim(from: 0.35, to: 0.65)
                .rotationEffect(Angle.degrees(45))
                .frame(width: size, height: size)
                .offset(y: -4)
                .shadow(color: gradientEnd, radius: 10)
                .shadow(color: gradientEnd, radius: 10)
                .shadow(color: gradientEnd, radius: 10)
        }
    }
}

struct AnnotationView_Previews: PreviewProvider {
    static var previewRestroom = exampleRestroom
    
    static var previews: some View {
        ContentView()
    }
}
