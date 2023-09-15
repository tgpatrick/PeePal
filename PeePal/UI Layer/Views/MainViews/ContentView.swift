//
//  ContentView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/10/20.
//
import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject var sharedModel = SharedModel()
    @StateObject var contentViewModel = ContentViewModel()
    @StateObject var searchViewModel = SearchViewModel()
    
    var body: some View {
        ZStack {
            // These spacers check the user's zoom level and how much they've scrolled on the map
            if (Float(contentViewModel.region.span.latitudeDelta) < 0.1) {
                Spacer()
                    .onAppear(perform: {
                        withAnimation {
                            sharedModel.reload()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                if (contentViewModel.region.span.latitudeDelta < 0.1 && sharedModel.getClosest()?.distance ?? 0 > 10) {
                                    contentViewModel.showAdd = true
                                }
                            }
                        }
                    })
                    .onDisappear(perform: {
                        sharedModel.clearData()
                    })
                    .onChange(of: contentViewModel.showSettings, perform: { _ in
                        if !contentViewModel.showSettings {
                            sharedModel.reload()
                        }
                    })
            }
            if (abs(Float(contentViewModel.region.center.latitude) - Float(self.contentViewModel.loadLocation.center.latitude)) > self.contentViewModel.reloadDistance
                || abs(Float(contentViewModel.region.center.longitude) - Float(self.contentViewModel.loadLocation.center.longitude)) > self.contentViewModel.reloadDistance) {
                Spacer()
                    .onAppear(perform: {
                        sharedModel.loadNew()
                    })
            }
            if (Float(contentViewModel.region.center.latitude) == Float(self.contentViewModel.detailRegion.center.latitude)
                && Float(contentViewModel.region.center.longitude) == Float(self.contentViewModel.detailRegion.center.longitude)) {
                Spacer()
                    .onDisappear(perform: {
                        sharedModel.clearScreen()
                    })
            }
            
            Map(
                coordinateRegion: $contentViewModel.region,
                showsUserLocation: true,
                annotationItems: sharedModel.restrooms
            ) { restroom in
                MapAnnotation(coordinate: restroom.getCoordinates(), anchorPoint: CGPoint(x: 0.5, y: 1)) {
                    AnnotationView(restroom: restroom, viewModel: sharedModel, contentViewModel: contentViewModel)
                        .onTapGesture {
                            contentViewModel.showDetail(restroom: restroom)
                        }
                }
            }
            .animation(.default)
            .onTapGesture {
                self.sharedModel.clearScreen()
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.sharedModel.reCenter(group: nil)
                }
            }
            .zIndex(1)
            
            VStack { // The main buttons
                HStack {
                    Spacer()
                    Button(action: {
                        contentViewModel.filterButton()
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .resizable()
                    }
                    
                    Spacer()
                    TextField(getSearchTitle(), text: $sharedModel.svm.searchText, onCommit: sharedModel.search)
                        .adaptiveShadow(radius: 15)
                        .frame(width: 200, height: 35, alignment: .center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onTapGesture {
                            withAnimation {
                                self.sharedModel.clearScreen()
                                self.contentViewModel.detailRegion = contentViewModel.region
                                contentViewModel.showSearch = true
                            }
                        }
                        .overlay(
                            HStack {
                                if !contentViewModel.showSearch {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 8)
                                }
                                Spacer()
                                if sharedModel.svm.searchText.count > 0 {
                                    Button(action: {
                                        sharedModel.clearScreen()
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                    Spacer()
                    
                    Button(action: {
                        self.contentViewModel.settingsButton()
                    }) {
                        Image(systemName: "gearshape.circle")
                            .resizable()
                    }
                    Spacer()
                }
                .padding()
                Spacer()
                if !contentViewModel.showSearch {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                self.sharedModel.clearScreen()
                                self.sharedModel.reCenter(group: nil)
                            }
                        }) {
                            Image(systemName: "location.north.circle")
                                .resizable()
                        }
                        
                        Spacer()
                        Button(action: {
                            withAnimation {
                                self.sharedModel.clearScreen()
                                self.sharedModel.urgent()
                            }
                        }) {
                            Text("URGENT")
                                .foregroundColor(.black)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .frame(width: 170)
                        .buttonStyle(PeePalButtonStyle(padding: 15, color: .red))
                        Spacer()
                        
                        Button(action: {
                            self.sharedModel.clearScreen()
                            self.sharedModel.getRestrooms(group: nil)
                        }) {
                            Image(systemName: "arrow.clockwise.circle")
                                .resizable()
                                .rotationEffect(.degrees(sharedModel.loadingRestrooms ? 360 : 0))
                                .animation(sharedModel.loadingRestrooms ? rotate : .easeOut, value: sharedModel.loadingRestrooms)
                                .transition(.identity)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 25)
                }
            }
            .buttonStyle(MapButtonStyle())
            .zIndex(2)
            Group {
                if contentViewModel.showFilter {
                    FilterView(sharedModel: sharedModel, filters: sharedModel.filters)
                        .transition(.scale(scale: 0.25, anchor: .topLeading))
                }
                if contentViewModel.showSearch {
                    SearchView(viewModel: sharedModel)
                        .transition(searchTransition)
                }
                if contentViewModel.showDetail {
                    RestroomView(restroom: contentViewModel.detailRestroom, viewModel: sharedModel)
                        .transition(restroomTransition)
                }
                if sharedModel.showTutorial {
                    TutorialView(sharedModel: sharedModel)
                }
                if contentViewModel.showAdd {
                    AddView(sm: sharedModel)
                }
            }
            .zIndex(3)
        }
        .sheet(isPresented: $contentViewModel.showSettings, content: {SettingsView(sharedModel: sharedModel, settings: sharedModel.settings)})
        .modifier(DismissingKeyboard())
        .onAppear {
            self.sharedModel.cvm = contentViewModel
            self.sharedModel.svm = searchViewModel
        }
    }
    
    func getSearchTitle() -> String {
        if self.contentViewModel.showSearch {
            return "Search"
        } else {
            return "      Search"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
