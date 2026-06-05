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
    case filter
    case map
    case search
    case end
    
    var id: String { rawValue }
    static let first: Self = .welcome
    static let last: Self = .end
}

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var scrollPosition: TutorialPage?
    @State private var locationManager: LocationManager = .init()
    private var pages: [TutorialPage] {
        var pages = TutorialPage.allCases
        if !showLocationPage {
            pages.removeAll(where: { $0 == .location })
        }
        return pages
    }
    
    private var showLocationPage: Bool {
        locationManager.authorizationStatus == .notDetermined
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(pages) { page in
                        Group {
                            switch page {
                            case .welcome:
                                WelcomeView()
                            case .location:
                                LocationPermissionView(locationManager: locationManager)
                                    .onDisappear {
                                        locationManager.requestLocation()
                                    }
                            case .filter:
                                RestroomTutorialView()
                            case .map:
                                MapTutorialView()
                            case .search:
                                SearchTutorialView()
                            case .end:
                                EndTutorialView()
                            }
                        }
                        .modifier(TutorialScreenModifier(id: page))
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
                .padding(.bottom, UIDevice.isIpad ? 16 : 0)
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
                scrollPosition = .filter
            }
        case .location:
            scrollPosition = .filter
        case .filter:
            scrollPosition = .map
        case .map:
            scrollPosition = .search
        case .search:
            scrollPosition = .end
        case .end:
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

