//
//  ContentView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/10/20.
//
import MapKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var sm: SharedModel
    @ObservedObject var vm = ContentViewModel()
    
    init(sharedModel: SharedModel = SharedModel()) {
        sm = sharedModel
//        sm.cvm = vm
        vm = sm.cvm
    }
    
    var body: some View {
        ZStack {
            // These spacers check the user's zoom level and how much they've scrolled on the map
            if (Float(vm.region.span.latitudeDelta) < 0.1) {
                Spacer()
                    .onAppear(perform: {
                        withAnimation {
                            sm.reload()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                if (vm.region.span.latitudeDelta < 0.1 && sm.getClosest()?.distance ?? 0 > 10) {
                                    vm.showAdd = true
                                }
                            }
                        }
                    })
                    .onDisappear(perform: {
                        sm.clearData()
                    })
                    .onChange(of: vm.showSettings, perform: { _ in
                        if !vm.showSettings {
                            sm.reload()
                        }
                    })
            }
            if (abs(Float(self.vm.region.center.latitude) - Float(self.vm.loadLocation.center.latitude)) > self.vm.reloadDistance
                    || abs(Float(self.vm.region.center.longitude) - Float(self.vm.loadLocation.center.longitude)) > self.vm.reloadDistance) {
                Spacer()
                    .onAppear(perform: {
                        sm.loadNew()
                    })
            }
            if (Float(self.vm.region.center.latitude) == Float(self.vm.detailRegion.center.latitude)
                    && Float(self.vm.region.center.longitude) == Float(self.vm.detailRegion.center.longitude)) {
                Spacer()
                    .onDisappear(perform: {
                        sm.clearScreen()
                    })
            }
            
            VStack {
            if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 14, minorVersion: 2, patchVersion: 0)) { // The app is only fully-featured on iOS 14.2+. This check will let me put in a UIKit Map for 13.0 - 14.1 when I get around to it.
                Map(
                    coordinateRegion: $vm.region,
                    interactionModes: MapInteractionModes.all,
                    showsUserLocation: true,
                    annotationItems: sm.restrooms
                ) { restroom in
                    MapAnnotation(
                        coordinate: vm.getCoordinates(restroom: restroom),
                        anchorPoint: CGPoint(x: 0.5, y: 1)
                    ) {
                        AnnotationView(restroom: restroom, viewModel: sm, contentViewModel: vm)
                            .animation(.spring())
                            .transition(.slide)
                    }
                }
                .animation(.default)
                .transition(.slide)
                .onTapGesture {
                    self.sm.clearScreen()
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.sm.reCenter(group: nil)
                    }
                })
            } else {
                Map(
                    coordinateRegion: $vm.region,
                    interactionModes: MapInteractionModes.all,
                    showsUserLocation: true,
                    annotationItems: sm.restrooms
                ) { restroom in
                    MapAnnotation(
                        coordinate: vm.getCoordinates(restroom: restroom),
                        anchorPoint: CGPoint(x: 0.5, y: 1)
                    ) {
                        AnnotationView(restroom: restroom, viewModel: sm, contentViewModel: vm)
                    }
                }
                .animation(.default)
                .onTapGesture {
                    self.sm.clearScreen()
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.sm.reCenter(group: nil)
                    }
                })
            }
            }
            VStack { // The main buttons
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .colorInvert()
                            .adaptiveShadow(radius: 15)
                            .frame(width: 45, height: 45, alignment: .center)
                        Button(action: {
                            vm.filterButton()
                        }) {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .resizable()
                                .frame(width: 45, height: 45, alignment: .center)
                        }
                    }
                    .frame(width: 45, height: 45, alignment: .center)
                    
                    Spacer()
                    TextField(getSearchTitle(), text: $sm.svm.searchText, onCommit: sm.search)
                        .adaptiveShadow(radius: 15)
                        .frame(width: 200, height: 35, alignment: .center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onTapGesture {
                            withAnimation {
                                self.sm.clearScreen()
                                self.vm.detailRegion = self.vm.region
                                vm.showSearch = true
                            }
                        }
                        .animation(.spring())
                        .overlay(
                            HStack {
                                if !vm.showSearch {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 8)
                                }
                                Spacer()
                                if sm.svm.searchText.count > 0 {
                                    Button(action: {
                                        sm.clearScreen()
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .colorInvert()
                            .frame(width: 45, height: 45, alignment: .center)
                            .adaptiveShadow(radius: 15)
                        Button(action: {
                            self.vm.settingsButton()
                        }) {
                            ZStack {
                                Image(systemName: "circle")
                                    .resizable()
                                Image(systemName: "gearshape")
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .center)
                            }
                        }
                    }
                    .frame(width: 45, height: 45, alignment: .center)
                    Spacer()
                }
                .padding()
                Spacer()
                if !vm.showSearch {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .colorInvert()
                                .adaptiveShadow(radius: 15)
                                .frame(width: 45, height: 45, alignment: .center)
                            Button(action: {
                                withAnimation {
                                    self.sm.clearScreen()
                                    self.sm.reCenter(group: nil)
                                }
                            }) {
                                Image(systemName: "location.circle")
                                    .resizable()
                                    .frame(width: 45, height: 45, alignment: .center)
                            }
                        }
                        .frame(width: 45, height: 45, alignment: .center)
                        
                        Spacer()
                        Button(action: {
                            withAnimation {
                                self.sm.clearScreen()
                                self.sm.urgent()
                            }
                        }) {
                            Text("URGENT")
                                .foregroundColor(.black)
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(15)
                        }
                        .background(Color.red)
                        .cornerRadius(15)
                        .frame(width: 170)
                        .adaptiveShadow(radius: 15)
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .colorInvert()
                                .adaptiveShadow(radius: 15)
                                .frame(width: 45, height: 45, alignment: .center)
                            Button(action: {
                                self.sm.clearScreen()
                                self.sm.getRestrooms(group: nil)
                            }) {
                                Image(systemName: "arrow.clockwise.circle")
                                    .resizable()
                                    .frame(width: 45, height: 45, alignment: .center)
                                    .rotationEffect(.degrees(sm.loadingRestrooms ? 360 : 0))
                                    .animation(sm.loadingRestrooms ? rotate : .easeOut)
                                    .transition(.identity)
                            }
                        }
                        .frame(width: 45, height: 45, alignment: .center)
                        Spacer()
                    }.padding(.bottom, 50)
                }
            }
            if (vm.showFilter) {
                FilterView(sharedModel: sm, filters: sm.filters)
                    .transition(.scale(scale: 0.5, anchor: .topLeading))
            }
            if (vm.showSearch) {
                SearchView(viewModel: sm)
                    .transition(searchTransition)
                    .animation(.easeInOut)
            }
            if (vm.showDetail) {
                RestroomView(restroom: vm.detailRestroom, viewModel: sm)
            }
            if (sm.showTutorial) {
                TutorialView(sharedModel: sm)
            }
            if (vm.showAdd) {
                AddView(sm: sm)
            }
        }
        .sheet(isPresented: $vm.showSettings, content: {SettingsView(sharedModel: sm, settings: sm.settings)})
        .modifier(DismissingKeyboard())
    }
    
    func getSearchTitle() -> String {
        if self.vm.showSearch {
            return "Search"
        } else {
            return "      Search"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(sharedModel: searchModel)
            .colorScheme(.dark)
            .onAppear(perform: {
                searchModel.showTutorial = false
            })
    }
}
