//
//  FilterView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/12/20.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var vm: SharedModel
    @ObservedObject var filters: Filters
    
    let accessibleRestroom = Restroom(
        id: 2,
        accessible: true,
        unisex: false,
        changingTable: true,
        distance: 1.0,
        downvote: 0,
        upvote: 1,
        latitude: 37.7749,
        longitude: -122.4194)
    
    let unisexRestroom = Restroom(
        id: 3,
        accessible: false,
        unisex: true,
        changingTable: true,
        distance: 1.0,
        downvote: 0,
        upvote: 1,
        latitude: 37.7749,
        longitude: -122.4194)
    
    init(sharedModel: SharedModel, filters: Filters) {
        self.vm = sharedModel
        self.filters = filters
    }
    
    var body: some View {
        VStack {
            Spacer()
                .frame(width: 0, height: 100, alignment: .center)
            VStack {
                ZStack {
                    VStack {
                        VStack {
                            Text("Filters")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Limit to:")
                                .font(.caption)
                        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        HStack {
                            AnnotationView_Old(restroom: accessibleRestroom, viewModel: vm, contentViewModel: ContentViewModel_Old())
                                .scaleEffect(CGSize(width: 0.5, height: 0.5))
                                .frame(width: 20, height: 20)
                            Toggle(isOn: $filters.accessFilter, label: {
                                Text("ADA accessible")
                            })
                            .onChange(of: filters.accessFilter, perform: { value in
                                UserDefaults.standard.setValue(value, forKey: "accessFilter")
                            })
                        }
                        HStack {
                            AnnotationView_Old(restroom: unisexRestroom, viewModel: vm, contentViewModel: ContentViewModel_Old())
                                .scaleEffect(CGSize(width: 0.5, height: 0.5))
                                .frame(width: 20, height: 20)
                            Toggle(isOn: $filters.unisexFilter, label: {
                                Text("Unisex available")
                            })
                            .onChange(of: filters.unisexFilter, perform: { value in
                                UserDefaults.standard.setValue(value, forKey: "unisexFilter")
                            })
                        }
                        /*
                         HStack {
                         Spacer()
                         .frame(width: 28, height: 25)
                         Toggle(isOn: $vm.tableFilter, label: {
                         Text("Has changing table")
                         })
                         }*/
                        Button(action: {
                            self.vm.clearScreen()
                            self.vm.getRestrooms(group: nil)
                        }) {
                            Text("Refresh")
                                .foregroundColor(.black)
                                .font(.title3)
                                .fontWeight(.bold)
                                .PeePalButton(padding: 7)
                        }
                        .frame(width: 200)
                    }
                    .padding()
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                vm.clearScreen()
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .scaleEffect(CGSize(width: 1.5, height: 1.5))
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                            }
                            .padding()
                        }
                        .padding(.top, 4)
                        Spacer()
                    }
                }
            }
            .frame(width: 300, height: 200)
            .defaultCard(cornerRadius: 25)
            Spacer()
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
//            ContentView(sharedModel: searchModel)
//                .onAppear(perform: {
//                    searchModel.showTutorial = false
//                })
            AnnotationView_Old(restroom: exampleRestroom, viewModel: SharedModel(), contentViewModel: ContentViewModel_Old())
            FilterView(sharedModel: SharedModel(), filters: Filters())
        }
//        .colorScheme(.dark)
    }
}
