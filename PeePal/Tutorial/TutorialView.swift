//
//  TutorialView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/30/20.
//

import SwiftUI

enum TutorialPage: String, Identifiable, CaseIterable {
    case welcome
    case location
    case map
    case filter
    case search
    
    var id: String { rawValue }
    static let first: Self = .welcome
    static let last: Self = .search
}

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var scrollPosition: TutorialPage?
    @State private var locationManager: LocationManager = .init()
    private let pages = TutorialPage.allCases
    
    private var showLocationPage: Bool {
        locationManager.authorizationStatus == .notDetermined
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(pages) { page in
                        switch page {
                        case .welcome:
                            WelcomeView()
                                .modifier(TutorialScreenModifier(id: page))
                        case .location:
                            if showLocationPage {
                                LocationPermissionView(locationManager: locationManager)
                                    .modifier(TutorialScreenModifier(id: page))
                                    .onDisappear {
                                        locationManager.requestLocation()
                                    }
                            }
                        case .map:
                            MapTutorialView()
                                .modifier(TutorialScreenModifier(id: .map))
                        default:
                            VStack {
                                Text(page.rawValue)
                                Spacer()
                            }
                            .font(.largeTitle)
                            .modifier(TutorialScreenModifier(id: page))
                        }
                    }
                    .containerRelativeFrame([.horizontal])
                    .background(.ultraThinMaterial)
                    .scrollTargetLayout()
                }
            }
            .scrollDisabled(true)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrollPosition)
            .scrollIndicators(.hidden)
            .animation(.bouncy, value: scrollPosition)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ToolBarDismissButton()
                }
            }
            .overlay(alignment: .bottomLeading) {
                Button(action: goToNextPage, label: {
                    HStack {
                        Spacer()
                        Text(scrollPosition == .last ? "Let's go!" : "Continue")
                        Spacer()
                    }
                })
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .modifier(GlassyOrProminentButton())
                .padding(.horizontal)
            }
            .onAppear(perform: goToNextPage)
        }
    }
    
    func goToNextPage() {
        switch scrollPosition {
        case .welcome:
            if showLocationPage {
                scrollPosition = .location
            } else {
                scrollPosition = .map
            }
        case .location:
            scrollPosition = .map
        case .map:
            scrollPosition = .filter
        case .filter:
            scrollPosition = .search
        case .search:
            dismiss()
        case .none:
            scrollPosition = TutorialPage.first
        }
    }
}

#if DEBUG
#Preview {
    Color.yellow
        .sheet(isPresented: .constant(true)) {
            TutorialView()
        }
}
#endif

