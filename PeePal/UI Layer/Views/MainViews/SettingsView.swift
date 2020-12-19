//
//  SettingsView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/12/20.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var sm: SharedModel
    @ObservedObject var settings: AppSettings
    @ObservedObject var vm = SettingsViewModel()
    
    init(sharedModel: SharedModel, settings: AppSettings) {
        self.sm = sharedModel
        self.settings = settings
    }
    
    var body: some View {
        VStack {
            ZStack {
                Text("PeePal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                HStack {
                    Spacer()
                    Button(action: {
                        sm.cvm.showSettings = false
                    }) {
                        Text("Done")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .PeePalButton(padding: 5, radius: 10)
                    }
//                    .buttonStyle(PeePalButtonStyle(padding: 5, radius: 10))
                }
            }
            VStack(alignment: .leading) {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Number of restrooms on screen: ")
                        Text("Default: 60 \nNote: Large numbers may lag,\n small numbers may not show all options")
                            .font(.caption)
                    }
                    Spacer()
                    Picker("", selection: $settings.numPerPage) {
                        ForEach(vm.numbers, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .onChange(of: settings.numPerPage, perform: { value in
                        UserDefaults.standard.setValue(value, forKey: "numPerPage")
                        sm.cvm.reloadDistance = Float(settings.numPerPage) * 0.0005
                    })
                    .frame(width: 55, height: 55)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                Toggle(isOn: $settings.useRegion, label: {
                    VStack(alignment: .leading) {
                        Text("Urgent button uses map view")
                        Text("Default: Your current location")
                            .font(.caption)
                    }
                })
                .onChange(of: settings.useRegion, perform: { value in
                    UserDefaults.standard.setValue(value, forKey: "useRegion")
                })
                Toggle(isOn: $settings.searchIgnoreFilters, label: {
                    Text("Ignore current filters in Search")
                })
                .onChange(of: settings.searchIgnoreFilters, perform: { value in
                    UserDefaults.standard.setValue(value, forKey: "searchIgnoreFilters")
                })
                Toggle(isOn: $settings.useGoogle, label: {
                    VStack(alignment: .leading) {
                        Text("Use Google Maps for directions")
                    }
                })
                .onChange(of: settings.useGoogle, perform: { value in
                    UserDefaults.standard.setValue(value, forKey: "useGoogle")
                })
            }
            Spacer()
            VStack {
                Text("Data for PeePal is provided by")
                Link("Refuge Restrooms", destination: URL(string: "https://www.refugerestrooms.org")!)
                    .font(.title)
                    .foregroundColor(Color("Unisex"))
                HStack {
                    Link(destination: URL(string: "https://www.refugerestrooms.org")!) {
                        HStack {
                            Image(systemName: "safari")
                                .foregroundColor(.black)
                            Text("Visit")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                        }
                        .padding(8)
                        .background(Color("Unisex"))
                        .cornerRadius(15)
                        .adaptiveShadow()
                    }
                    .padding(.horizontal)
                    Link(destination: URL(string: "https://www.refugerestrooms.org/restrooms/new")!) {
                        HStack {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                            Text("Add")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                        }
                        .padding(8)
                        .background(Color("Unisex"))
                        .cornerRadius(15)
                        .adaptiveShadow()
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(15)
            Spacer()
        }
        .padding()
        .background(Color("AdaptiveBackground"))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(sharedModel: SharedModel(), settings: AppSettings())
//            .colorScheme(.dark)
    }
}
