//
//  MapItemAnnotation.swift
//  PeePal
//
//  Created by Thomas Patrick on 04/03/26.
//

import SwiftUI
import MapKit

public struct MapItemAnnotation: View {
    public let mapItem: MKMapItem

    @State private var isShowing = false
    
    private var iconSize: CGFloat { 20 }
    private var iconPadding: CGFloat { iconSize * 0.4 }
    private var iconBottomPadding: CGFloat { iconPadding / 2 }

    public init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }

    public var body: some View {
        VStack {
            Spacer()
            if isShowing {
                Image(systemName: mapItemIconName(for: mapItem))
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconSize)
                    .foregroundStyle(.black)
                    .padding(iconPadding)
                    .padding(.bottom, iconBottomPadding)
                    .background(
                        alignment: .bottom,
                        content: {
                            MapPoint(heightRadiusRatio: 1.5)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(.accent), Color(.accentColorLight)],
                                        startPoint: .init(x: 0.5, y: 0.2),
                                        endPoint: .init(x: 0.5, y: 0.6)
                                    )
                                    .shadow(.inner(color: .black.opacity(0.25), radius: 5))
                                )
                                .shadow(radius: 5)
                                .background {
                                    MapShadowPoint(
                                        gradientStart: Color(.accent),
                                        gradientEnd: Color(.accentColorLight),
                                        size: iconSize * 1.4
                                    )
                                }
                        }
                    )
                    .zIndex(2)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.1, anchor: .bottom),
                            removal: .scale(scale: 0.1, anchor: .bottom)
                                .combined(with: .opacity)
                        )
                    )
            }
        }
        .frame(width: 44, height: 50)
        .fixedSize()
        .onAppear {
            withAnimation(.interactiveSpring(extraBounce: 0.5)) {
                isShowing = true
            }
        }
    }

    private func mapItemIconName(for item: MKMapItem) -> String {
        if item.pointOfInterestCategory == .airport {
            return "airplane"
        } else if item.pointOfInterestCategory == .restaurant {
            return "fork.knife"
        } else if item.pointOfInterestCategory == .hotel {
            return "bed.double"
        } else if item.pointOfInterestCategory == .store {
            return "cart"
        } else {
            return "mappin"
        }
    }
}

// MARK: - Supporting Shapes (copied/renamed from AnnotationView for selected look)

struct MapPoint: Shape {
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

struct MapShadowPoint: View {
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
