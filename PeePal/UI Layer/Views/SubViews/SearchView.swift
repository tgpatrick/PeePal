//
//  SearchView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/15/20.
//

import SwiftUI
import MapKit
import Combine

struct SearchView: View {
    @ObservedObject var sm: SharedModel
    @ObservedObject var vm: SearchViewModel = SearchViewModel()
    @Namespace private var matchedViews
    
    init(viewModel: SharedModel) {
        self.sm = viewModel
        vm = sm.svm
    }
    var body: some View {
        VStack {
            VStack {
                if vm.searchResults.count > 0 {
                    resultsView
                } else if !vm.searching {
                    searchButtons
                } else {
                    loadingView
                }
            }
            .frame(width: vm.searchResults.count == 0 ? 200 : 300, height: vm.searchResults.count == 0 ? 100 : 300)
            .defaultCard()
            .padding(.top, 80)
        Spacer()
        }
    }
    
    var searchButtons: some View {
        HStack {
            Spacer()
            Button(action: {
                sm.search()
            }) {
                Text("Search")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
            }
            .buttonStyle(PeePalButtonStyle(padding: 5, radius: 10))
            
            Spacer()
            
            Button(action: {
                sm.clearScreen()
            }) {
                Text("Cancel")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
            }
            .buttonStyle(PeePalButtonStyle(padding: 5, radius: 10))
            
            Spacer()
        }
    }
    
    var loadingView: some View {
        VStack {
            Text("Loading...")
                .font(.title2)
            Image(systemName: "arrow.clockwise")
                .scaleEffect(CGSize(width: 1.5, height: 1.5))
                .rotationEffect(.degrees(vm.spinning ? 360 : 0))
                .animation(rotate, value: vm.spinning)
                .transition(.identity)
                .matchedGeometryEffect(id: "spinner", in: matchedViews)
                .onAppear(perform: {
                    vm.spinning = true
                })
                .onDisappear(perform: {
                    vm.spinning = false
                })
                .padding(.top, 10)
        }
        .onChange(of: vm.searchText, perform: { _ in
            vm.searching = false
        })
    }
    
    var resultsView: some View {
        List {
            ForEach(vm.searchResults) { restroom in
                RestroomSearchView(sharedModel: sm, restroom: restroom)
                    .transition(.slide)
            }
        }
    }
}

var searchModel = SharedModel()

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ContentView()
            SearchView(viewModel: searchModel)
        }
    }
}
