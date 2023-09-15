//
//  TutorialView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/30/20.
//

import SwiftUI

struct TutorialView: View {
    @ObservedObject var sm = SharedModel()
    @ObservedObject var vm = TutorialViewModel(sharedModel: SharedModel())
    
    init(sharedModel: SharedModel) {
        sm = sharedModel
        vm = TutorialViewModel(sharedModel: sm)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(0.7)
                .onTapGesture {
                    vm.done()
                }
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .colorInvert()
                            .adaptiveShadow(radius: 15)
                            .frame(width: 45, height: 45, alignment: .center)
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .resizable()
                            .frame(width: 45, height: 45, alignment: .center)
                            .foregroundColor(Color("AccentColor"))
                    }.frame(width: 45, height: 45, alignment: .center)
                    Spacer()
                    Spacer().frame(width: 200, height: 35, alignment: .center)
                    Spacer()
                    ZStack {
                        Circle()
                            .colorInvert()
                            .frame(width: 45, height: 45, alignment: .center)
                            .adaptiveShadow(radius: 15)
                        ZStack {
                            Image(systemName: "circle")
                                .resizable()
                                .foregroundColor(Color("AccentColor"))
                            Image(systemName: "gearshape")
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .center)
                                .foregroundColor(Color("AccentColor"))
                        }
                    }
                    .frame(width: 45, height: 45, alignment: .center)
                    Spacer()
                }.padding()
                HStack {
                    Spacer()
                    VStack {
                        Image("arrow.curve.down")
                            .resizable()
                            .frame(width: 45, height: 45, alignment: .center)
                            .colorInvert()
                            .rotationEffect(.degrees(120))
                        Text("Filters")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentColor"))
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    .padding(.leading, 5)
                    Spacer()
                    Spacer()
                        .frame(width: 5, height: 35, alignment: .center)
                    Spacer()
                    VStack {
                        Image("arrow.curve.up")
                            .resizable()
                            .frame(width: 45, height: 45, alignment: .center)
                            .colorInvert()
                            .rotationEffect(.degrees(60))
                        Text("Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentColor"))
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    .padding(.trailing, 5)
                    Spacer()
                }
                Spacer()
                Button(action: vm.done) {
                    Text("Done")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .font(.title2)
                }
                .buttonStyle(PeePalButtonStyle(padding: 5, radius: 5))
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Text("Find You")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentColor"))
                        Image("arrow.curve.down")
                            .resizable()
                            .frame(width: 45, height: 45, alignment: .center)
                            .colorInvert()
                            .rotationEffect(.degrees(-55))
                            .padding(.trailing, 80)
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    .padding(.leading, 5)
                    Spacer()
                    VStack {
                        Text("Find Nearest")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentColor"))
                        Image("arrow.curve.up")
                            .resizable()
                            .frame(width: 45, height: 45, alignment: .center)
                            .colorInvert()
                            .rotationEffect(.degrees(220))
                    }
                    .frame(width: 130, height: 100, alignment: .center)
                    Spacer()
                    VStack {
                        Text("Reload")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentColor"))
                        Image("arrow.curve.up")
                            .resizable()
                            .frame(width: 45, height: 45, alignment: .center)
                            .colorInvert()
                            .rotationEffect(.degrees(225))
                            .padding(.leading, 80)
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    .padding(.trailing, 5)
                    Spacer()
                }
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .colorInvert()
                            .adaptiveShadow(radius: 15)
                            .frame(width: 45, height: 45, alignment: .center)
                        Image(systemName: "location.circle")
                            .resizable()
                            .frame(width: 45, height: 45, alignment: .center)
                            .foregroundColor(Color("AccentColor"))
                    }
                    .frame(width: 45, height: 45, alignment: .center)
                    
                    Spacer()
                    Text("URGENT")
                        .foregroundColor(.black)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(15)
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
                        Image(systemName: "arrow.clockwise.circle")
                            .resizable()
                            .frame(width: 45, height: 45, alignment: .center)
                            .foregroundColor(Color("AccentColor"))
                    }
                    .frame(width: 45, height: 45, alignment: .center)
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
            }
        }
    }
}

var tutorialModel = SharedModel()

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ContentView()
            TutorialView(sharedModel: tutorialModel)
                .onAppear(perform: {
                    tutorialModel.showTutorial = true
                })
        }
    }
}
