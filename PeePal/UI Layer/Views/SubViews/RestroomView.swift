//
//  RestroomView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/14/20.
//

import SwiftUI

struct RestroomView: View {
    @ObservedObject var vm: SharedModel
    var restroom: Restroom
    let textSpace: CGFloat = 15
    let opac = 0.2
    let shortHeight: CGFloat = 250
    let tallHeight: CGFloat = 500
    @State var expanded = false
    @State var useExpandedMask = false
    @Environment(\.colorScheme) var colorScheme
    
    var appLogic: AppLogic
    
    init(restroom: Restroom, viewModel: SharedModel) {
        self.restroom = restroom
        self.vm = viewModel
        appLogic = viewModel.appLogic
    }
    
    func friendlyBool(bool: Bool) -> String {
        if bool {
            return "Yes"
        } else {
            return "No"
        }
    }
    
    func getColor() -> Color {
        if restroom.upvote > restroom.downvote {
            return .green
        } else if restroom.upvote < restroom.downvote {
            return .red
        } else {
            return .gray
        }
    }
    
    func getPercent() -> String {
        let total = restroom.upvote + restroom.downvote
        var percent: Double
        if total == 0 {
            return "Not Yet Rated"
        } else if restroom.upvote == restroom.downvote {
            return "Neutral Ratings"
        }
        percent = (Double(restroom.upvote) / Double(restroom.upvote + restroom.downvote)) * 100
        return String(Int(percent)) + "% Positive"
    }
    
    var body: some View {
        ZStack {
            ZStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        VStack { // Header
                            Spacer()
                                .frame(width: 0, height: 20, alignment: .center)
                            Text(restroom.name ?? "Name Unknown")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text(getPercent())
                                .font(.footnote)
                                .fontWeight(.bold)
                                .padding(5)
                                .frame(width: 150)
                                .background(getColor().opacity(0.6))
                                .cornerRadius(10)
                            HStack {
                                if restroom.unisex {
                                    ZStack {
                                        if colorScheme == .light {
                                            Image("Unisex")
                                                .scaleEffect(CGSize(width: 0.35, height: 0.35))
                                        } else {
                                            Image("Unisex")
                                                .scaleEffect(CGSize(width: 0.35, height: 0.35))
                                                .colorInvert()
                                        }
                                    }
                                    .frame(width: 35, height: 35)
                                    .padding(5)
                                    .background(Color.secondary.opacity(opac))
                                    .cornerRadius(5)
                                    .shadow(radius: 1)
                                }
                                if restroom.accessible {
                                    ZStack {
                                        if colorScheme == .light {
                                            Image("Accessible")
                                                .scaleEffect(CGSize(width: 0.35, height: 0.35))
                                        } else {
                                            Image("Accessible")
                                                .scaleEffect(CGSize(width: 0.35, height: 0.35))
                                                .colorInvert()
                                        }
                                    }
                                    .frame(width: 35, height: 35)
                                    .padding(5)
                                    .background(Color.secondary.opacity(opac))
                                    .cornerRadius(5)
                                    .shadow(radius: 1)
                                }
                                if restroom.changing_table {
                                    ZStack {
                                        if colorScheme == .light {
                                            Image("ChangingTable")
                                                .scaleEffect(CGSize(width: 0.17, height: 0.17))
                                        } else {
                                            Image("ChangingTable")
                                                .scaleEffect(CGSize(width: 0.17, height: 0.17))
                                                .colorInvert()
                                        }
                                    }
                                    .frame(width: 35, height: 35)
                                    .padding(5)
                                    .background(Color.secondary.opacity(opac))
                                    .cornerRadius(5)
                                    .shadow(radius: 1)
                                }
                            }
                        }
                        VStack(spacing: textSpace) { // Info
                            VStack {
                                Text((restroom.street ?? "Unknown"))
                                Text((restroom.city ?? "") + ", " + (restroom.state ?? ""))
                            }
                        }
                        .padding(.bottom, textSpace)
                        VStack(alignment: .leading, spacing: textSpace) { // Special instructions/comments
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("   Special directions:").fontWeight(.bold)
                                    Spacer()
                                }
                                Text(restroom.directions ?? "None")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("   Special comments:").fontWeight(.bold)
                                    Spacer()
                                }
                                Text(restroom.comment ?? "None")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(textSpace)
                    .padding(.bottom, 55)
                    .padding(.vertical, 5)
                }
                VStack {
                    HStack { // Expand + Dismiss buttons
                        Button(action: {
                            withAnimation(.easeInOut) {
                                expanded.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + (expanded ? 0.1 : 0.3)) {
                                    useExpandedMask.toggle()
                                }
                            }
                        }) {
                            Image(systemName:
                                    expanded ?
                                    "arrow.down.forward.and.arrow.up.backward.circle.fill" :
                                    "arrow.up.backward.and.arrow.down.forward.circle.fill")
                                .scaleEffect(CGSize(width: 1.5, height: 1.5))
                                .foregroundColor(.gray)
                                .opacity(0.5)
                                .padding()
                        }
                        Spacer()
                        Button(action: {
                            vm.cvm.showDetail = false
                            vm.clearScreen()
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .scaleEffect(CGSize(width: 1.5, height: 1.5))
                                .foregroundColor(.gray)
                                .opacity(0.5)
                                .padding()
                        }
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    HStack { // Directions + Rate buttons
                        Link(destination: appLogic.directionsURL(restroom: restroom)) {
                            HStack {
                                Image(systemName: "map")
                                    .foregroundColor(.black)
                                Text("Directions")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                            }
                        }
                        .buttonStyle(PeePalButtonStyle())
                        .padding()
                        Link(destination: appLogic.makeEditURL(restroom: restroom)) {
                            HStack {
                                Image(systemName: "star")
                                    .foregroundColor(.black)
                                Text("Rate")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                            }
                        }
                        .buttonStyle(PeePalButtonStyle())
                        .padding()
                    }
                }
                .padding(.bottom, expanded ? tallHeight / 20 : shortHeight / 20)
            }
        }
        .frame(width: 300, height: expanded ? tallHeight : shortHeight)
        .background(.thinMaterial)
        .mask(DetailShape(expanded: useExpandedMask))
        .adaptiveShadow(radius: 10)
        .offset(y: expanded ? -45 : -170)
    }
}

struct RestroomView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.yellow.ignoresSafeArea(.all)
            AnnotationView(restroom: exampleRestroom, viewModel: searchModel, contentViewModel: ContentViewModel())
                .offset(y: -23)
            RestroomView(restroom: exampleRestroom, viewModel: searchModel)
        }
    }
}
